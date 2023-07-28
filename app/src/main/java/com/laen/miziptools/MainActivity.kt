package com.laen.miziptools

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.nfc.NfcAdapter
import android.nfc.NfcAdapter.getDefaultAdapter
import android.nfc.Tag
import android.nfc.tech.MifareClassic
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.ui.text.toUpperCase
import com.laen.miziptools.databinding.ActivityMainScreenBinding
import com.laen.miziptools.databinding.ActivityWriteNewBinding
import java.io.File
import com.laen.miziptools.databinding.ActivityChangeIdBinding
import com.laen.miziptools.databinding.ActivityRechargeKeyBinding
import java.util.Locale

class MainActivity : ComponentActivity() {

    // Tout ce qui gère le choix du fichier
    // Activité qui va ouvrir le file picker
    val dirRequest = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        uri?.let {
            // call this to persist permission across decice reboots
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            // do your stuff
            this.uriFichier = uri
            writeNewBinding.fichierDump.setText(uri.path.toString().split("/").last())
        }
    }

    //Contexte pour la localisation
    lateinit var context: Context

    // Var qui contient l'URI du fichier
    var uriFichier : Uri? = null

    // Reges pour vérification des entrées
    val regexUID = """^[a-fA-F0-9X]{8}$"""
    val regexCle = """^[a-fA-F0-9]{12}$"""

    // Pour le layout
    lateinit var writeNewBinding: ActivityWriteNewBinding
    private lateinit var mainBinding : ActivityMainScreenBinding
    private lateinit var rechargeBinding : ActivityRechargeKeyBinding
    private lateinit var changeIdBinding : ActivityChangeIdBinding

    // CLés et UID connus à partir desquels on va calculer les clés du MiZip
    private val baseKeyAList = listOf("6421E1E7E4D6", "C64672F5FF1C", "8F41FA6D413A", "5C490CED29A3")
    private val baseKeyBList = listOf("4AEEE96063E3", "C825F4CD8983", "118F7E45ED6C", "0BD14A14963F")
    private val baseUid = "6D33BBC2"

    // Valeur déduite du solde actuel (car la clé stocke ancien solde et nouveau solde
    private val deduction = 0.37

    // Objet qui gère l'écriture
    private val keyWriter = KeyWriter(this)
    //objet qui gère le tag
    lateinit var nfcWrapper : NFCWrapper

    // Données de base d'une clé, utilisé pour la remise à 0
    private val baseCle = """4c61656e26890400c834002000000016
00000000000000000000000000000000
00000000000000000000000000000000
FFFFFFFFFFFFFF078069FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
FFFFFFFFFFFFFF078069FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
FFFFFFFFFFFFFF078069FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
FFFFFFFFFFFFFF078069FFFFFFFFFFFF
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
FFFFFFFFFFFFFF078069FFFFFFFFFFFF""".uppercase(Locale("EN"))

    // FOnction qui affcihe un message d'erraur de saisie incorrecte
    fun displayErrorMessage(msg : String){
        Toast.makeText(this, getString(R.string.erreur_dans_le_param) + msg, Toast.LENGTH_SHORT).show()
    }

    // Fonctions qui permettent de calculer les clés A et B
    private fun calcKeyA(uid : String) = (uid + uid.slice(0..3))
    private fun calcKeyB(uid : String) = (uid.slice(4..7) + uid)

    private fun calcKey(target_uid : String, keys_list : List<String>, generatingFunc : (String) -> String): List<String>
    {
        // Calcule les clés à partir de l'UID de base et des clés connues, renvoie la liste
        // Calcul de l'uid
        val uid = target_uid.toLong(16) xor baseUid.toLong(16)
        // Création de la clé de base
        val intermediateKey = generatingFunc(uid.toString(16).padStart(8, '0'))
        // Grâce à chaque clé de la liste, on génère la clé pour l'UID
        return keys_list.map {(it.toLong(16) xor intermediateKey.toLong(16))}.map{it.toString(16).padStart(12, '0')}
    }

    // Fonction qui retourne toutes les clés A et B d'un UID Donné
    fun getAllKeys(uid : String) : Pair<List<String>, List<String>>{
        val keysA = listOf("a0a1a2a3a4a5") + calcKey(uid, baseKeyAList, ::calcKeyA)
        val keysB = listOf("b4c123439eef") + calcKey(uid, baseKeyBList, ::calcKeyB)
        return Pair(keysA, keysB)
    }

    // Sauvegarde la dump dans un fichier dont le nom est l'UID
    private fun saveDump(infos : String?, nomFichier : String){
        // Vérification que les infos sont ok
        infos ?: return
        val path = getExternalFilesDir(null)
        val file = File(path, nomFichier)
        file.appendText(infos.uppercase(Locale("EN")))
        Toast.makeText(this, getString(R.string.dump_effectue_fichier) + nomFichier, Toast.LENGTH_SHORT).show()
    }

    // Ajoute les clés à la fin des blocks dans le dump
    private fun traiterDump(dump : String, lKeyA : List<String>, lKeyB : List<String>) : String{

        val dumpListe = dump.lines()
        var resultat = ""
        for (i in 0 until(dumpListe.size - 1)){
            resultat += if (i%4 == 3){
                lKeyA[i/4] + dumpListe[i].slice(12..19 ) + lKeyB[i/4]
            } else{
                dumpListe[i]
            }
            resultat += "\n"
        }

        return resultat
    }

    // Fonction qui va faire le dump, elle renvoie un String
    private fun dumpCleMizip() : String?{

        // Vars qui contiennent ce qu'on va ecrire dans les fichiers
        var contenuDump = ""
        // On reconstitue l'UID
        val targetUid = nfcWrapper.getKeyUID()
        // Calcul des clés
        val (listKeysA, listKeysB) = getAllKeys(targetUid).toList()
        // On est connecté, pour chaque block (20 au total) on lit les infos, tous les 4 blocks on
        // s'authentifie avec la bonne clé
        for (i in 0..19){
            try {
                contenuDump += nfcWrapper.readBlock(i, listKeysA[i / 4], i / 4) + "\n"
            }catch (e : android.nfc.TagLostException){
                Toast.makeText(this, getString(R.string.erreur_tag_enleve), Toast.LENGTH_SHORT).show()
                return null
            }catch (e : java.io.IOException){
                Toast.makeText(this, getString(R.string.erreur_de_communication), Toast.LENGTH_SHORT).show()
                return null
            }
        }
        // Formatage, et retour du dump
        return traiterDump(contenuDump, listKeysA, listKeysB)
    }

    // Instancie un NFCWrapper
    private fun connectToTag(tag : Tag) : NFCWrapper {
        // On crée l'objet NFCWrapper
        nfcWrapper = NFCWrapper(MifareClassic.get(tag))

        // On affiche à l'utilisateur qu'on a trouvé un tag
        this.runOnUiThread { Toast.makeText(this, getString(R.string.nouveau_tag_trouv) + nfcWrapper.getKeyUID(), Toast.LENGTH_SHORT).show() }

        // On le renvoie
        return nfcWrapper

    }

    // Fonction qui va servir à recharger la clé
    private fun rechargerCle(nouveauSolde : String){

        // On vérifie si le solde est ok
        val nouveauSolde = if (nouveauSolde.isNotEmpty() && nouveauSolde.toFloat() < 655.34 ) {nouveauSolde} else { displayErrorMessage(getString(
                    R.string.solde)); return }

        // On récupère l'UID
        val uid = nfcWrapper.getKeyUID()

        // On génère les clés A et B, et on récupère uniquemment celle qui nous intéresse : celle du secteur 2
        val cleA = calcKey(uid, baseKeyAList, ::calcKeyA)[1]
        val cleB = calcKey(uid, baseKeyBList, ::calcKeyB)[1]

        // On récupère seulement les deux lignes qui ont à voir avec le solde
        // Blocks 8 et 9 Secteur 2
        val ancienSolde = nfcWrapper.readBlock(9, cleA, 2)
        val soldeActuel = nfcWrapper.readBlock(8, cleA, 2)

        // On récupère le nouveau solde que l'on veut et son solde antérieur + leur checksum
        val nouveauSoldeAct = keyWriter.traiterSolde(nouveauSolde)
        val nouveauSoldeAnt = keyWriter.traiterSolde((nouveauSolde.toFloat() + deduction).toString())

        // On remplace dans les deux lignes
        val ligneNouveauAnt = ancienSolde.replace(ancienSolde.slice(2..7), nouveauSoldeAnt)
        val ligneNouveauAct = soldeActuel.replace(soldeActuel.slice(2..7), nouveauSoldeAct)

        // On écrit les deux lignes
        nfcWrapper.writeBlock(ligneNouveauAnt, 2, 8, cleA, cleB)
        nfcWrapper.writeBlock(ligneNouveauAct, 2, 9, cleA, cleB)

        Toast.makeText(this, getString(R.string.cle_rechargee_avec_succes), Toast.LENGTH_SHORT).show()
    }

    // Fonction qui change l'ID de la clé, et modifie ses clés
    private fun changerIdCle(uid : String){
        // Verification si l'UID est ok
        val uid = if (uid.matches(Regex(regexUID))) {uid} else { displayErrorMessage("UID"); return }

        // On a le nouvel UID, on calcule son BCC
        val newUid = keyWriter.generateUidBcc(uid)
        Log.d("UID", uid)
        // On récupère la liste des clés
        val listeCles = getAllKeys(uid)
        val oldKeys = getAllKeys(nfcWrapper.getKeyUID())
        // On génère le dump de la clé actuelle, si erreur lors du dump, on return
        var dump = dumpCleMizip() ?: return
        // On le modifie pour changer les clés
        dump = traiterDump(dump, listeCles.first, listeCles.second)
        // On modifie la première ligne pour changer l'UID et le BCC
        dump = dump.replace(dump.slice(0..9), newUid)
        // On peut écrire le dump sur la clé
        keyWriter.ecritureCle(dump, oldKeys.first, oldKeys.second)

        Toast.makeText(this, getString(R.string.uid_change_avec_succes), Toast.LENGTH_SHORT).show()
    }

    // Fonction qui reset la clé, On laisse son UID, mais on Passe toutes ses clés à FFFFFFFFFFFF
    private fun resetCle(){
        // On prend l'UID de la clé actuelle
        val uid = nfcWrapper.getKeyUID()
        // On récupère ses clés
        val (kA, kB) = getAllKeys(uid).toList()
        // On écrit la clé de base, on catch les erreurs possibles
        try {
            keyWriter.ecritureCle(baseCle, kA, kB)
        }catch(e : android.nfc.TagLostException){
            runOnUiThread {
                Toast.makeText(
                    context,
                    context.getString(R.string.erreur_lors_de_l_criture_sur_le_tag),
                    Toast.LENGTH_LONG
                ).show()
            }
            return
        }
            Toast.makeText(this, getString(R.string.cle_reinitialisee_avec_succes), Toast.LENGTH_SHORT).show()
    }

    // Ecran du menu de changement d'UID
    private fun ecranChangeId(){
        setContentView(changeIdBinding.root)
        changeIdBinding.buttonChId.setOnClickListener { changerIdCle(changeIdBinding.nouveauUid.text.toString()) }
    }

    // Ecran du menu écrire une nouvelle clé
    private fun ecranEcrireNouvelleCle(){

        setContentView(writeNewBinding.root)
        writeNewBinding.choisirFichier.setOnClickListener { keyWriter.choisirFichier()}

        writeNewBinding.writeNewKey.setOnClickListener { keyWriter.ecrireNouvelleCle(writeNewBinding.uidBase.text.toString(),
            writeNewBinding.nouveauSolde.text.toString()) }

    }

    // Ecran du menu de recharge
    private fun ecranRechargerCle(){
        setContentView(rechargeBinding.root)
        rechargeBinding.buttonRecharge.setOnClickListener { rechargerCle(rechargeBinding.nouveauSoldeRecharge.text.toString()) }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Context
        context = applicationContext

        mainBinding = ActivityMainScreenBinding.inflate(layoutInflater)
        writeNewBinding = ActivityWriteNewBinding.inflate(layoutInflater)
        rechargeBinding = ActivityRechargeKeyBinding.inflate(layoutInflater)
        changeIdBinding = ActivityChangeIdBinding.inflate(layoutInflater)

        setContentView(mainBinding.root)

        mainBinding.dumpKey.setOnClickListener { saveDump(dumpCleMizip(), nfcWrapper.getKeyUID()+ ".txt") }
        mainBinding.writeNewKey.setOnClickListener { ecranEcrireNouvelleCle() }
        mainBinding.rechargeKey.setOnClickListener { ecranRechargerCle() }
        mainBinding.changeUid.setOnClickListener { ecranChangeId() }
        mainBinding.activateReset.setOnClickListener {mainBinding.resetKey.isEnabled = mainBinding.activateReset.isChecked }
        mainBinding.resetKey.setOnClickListener { resetCle() }
    }

    override fun onStart() {
        super.onStart()
        // Some setup for NFC stuff
        val nfcAdapter = getDefaultAdapter(context)
        nfcAdapter.enableReaderMode(this,
            { tag -> connectToTag(tag) }, NfcAdapter.FLAG_READER_NFC_A , null)
    }

    override fun onStop() {
        super.onStop()
        getDefaultAdapter(context).disableReaderMode(this)
    }
}
