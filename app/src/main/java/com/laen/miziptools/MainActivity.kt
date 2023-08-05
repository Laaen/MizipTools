package com.laen.miziptools

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.nfc.NfcAdapter
import android.nfc.NfcAdapter.getDefaultAdapter
import android.nfc.Tag
import android.nfc.TagLostException
import android.nfc.tech.MifareClassic
import android.os.Bundle
import android.util.Log
import android.widget.ArrayAdapter
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.core.net.toUri
import com.laen.miziptools.databinding.ActivityMainScreenBinding
import com.laen.miziptools.databinding.ActivityWriteNewBinding
import com.laen.miziptools.databinding.ActivityChangeIdBinding
import com.laen.miziptools.databinding.ActivityRechargeKeyBinding
import com.laen.miziptools.databinding.ActivityViewDumpBinding
import java.io.FileNotFoundException
import java.io.IOException
import java.lang.Exception
import java.util.Locale

/*
    MizipTools : Android app to fiddle with MiZip tags

    05/08/2023                                 By Laen
 */




class MainActivity : ComponentActivity() {

    // ================================ Attributes ======================================

    //Contexte pour la localisation
    lateinit var context: Context

    // Reges pour vérification des entrées
    val regexUIDRand = """^[a-fA-F0-9X]{8}$"""
    val regexUid = """^[a-fA-F0-9]{8}$"""
    val regexCle = """^[a-fA-F0-9]{12}$"""

    // Pour le layout
    lateinit var writeNewBinding: ActivityWriteNewBinding
    private lateinit var mainBinding : ActivityMainScreenBinding
    private lateinit var rechargeBinding : ActivityRechargeKeyBinding
    private lateinit var changeIdBinding : ActivityChangeIdBinding
    private lateinit var viewDumpBinding: ActivityViewDumpBinding

    // Objet qui gère la lecture / écriture des fichiers
    private lateinit var fileWrapper : FileWrapper
    // Objet qui regroupe des fonctions
    val utils = Utils()
    var nfcWrapper : NFCWrapper? = null

    // Le thread d'update
    var threadUpdate : Thread? = null
    var continuer : Boolean = true

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

    // ================================ Fonctions du Thread Update ==============================

    // Fonctions qui stoppent le thread de mise à jour et le redémarrent
    fun stopThreadUpdate(){
        continuer = false
        Thread.sleep(1000)
    }

    fun startThreadUpdate(){
        continuer = true
        threadUpdate = Thread { updateTagInfo() }
        threadUpdate!!.start()
    }

    // Fonction qui va pool toutes les x secondes les infos du tag (utilisé pour savoir si le tag est toujours là
    private fun updateTagInfo(){
        // Met ensuite à jour l'UID et/ou le solde
        while (continuer) {
            var uid = "N/A"
            var solde = "N/A"
            try {
                Thread.sleep(1000)
                //On change le texte du tableau du menu principal
                Log.d("", "Boucle")
                uid = nfcWrapper!!.getKeyUID()
                // On essaie d'avoir le solde, si on y arrive pas, on ne touche pas au texte
                solde = getSolde() + getString(R.string.euros)
            } catch (e: TagLostException) {
                tagDisconnected()
                return
            }catch (e: IOException) {
                this.runOnUiThread { mainBinding.infotagMoney.text = "N/A" }
            } catch (e: InterruptedException) {
                return
            }catch(e: Exception){

            }
            this.runOnUiThread { mainBinding.infotagMoney.text = solde }
            this.runOnUiThread { mainBinding.infoTagUID.text = uid}
        }
    }

    // ================================ Connexion et déconnexion du tag ==============================

    // Switche les boutons on ou off
    fun switchButtons(bool : Boolean){
        this.runOnUiThread { mainBinding.dumpKey.isEnabled = bool }
        this.runOnUiThread { mainBinding.writeNewKey.isEnabled = bool }
        this.runOnUiThread { mainBinding.rechargeKey.isEnabled = bool }
        this.runOnUiThread { mainBinding.changeUid.isEnabled = bool }
        this.runOnUiThread { mainBinding.activateReset.isEnabled = bool }

        this.runOnUiThread { rechargeBinding.buttonRecharge.isEnabled = bool }
        this.runOnUiThread { changeIdBinding.buttonChId.isEnabled = bool }
        this.runOnUiThread {  writeNewBinding.writeNewKey.isEnabled = bool }
    }

    // Instancie un NFCWrapper
    private fun connectToTag(tag : Tag){

        // On crée l'objet NFCWrapper
        this.nfcWrapper = NFCWrapper(MifareClassic.get(tag))

        // On affiche à l'utilisateur qu'on a trouvé un tag
        this.runOnUiThread { Toast.makeText(this, getString(R.string.nouveau_tag_trouv) + nfcWrapper!!.getKeyUID(), Toast.LENGTH_SHORT).show() }

        // On active tous les boutons possibles
        switchButtons(true)

        // Thread pour l'actualisation des infos / detection du tag enlevé
        startThreadUpdate()
    }

    // Appelé lorsque le tag est enlevé
    private fun tagDisconnected(){

        stopThreadUpdate()

        // ON affiche un message à l'utilisateur
        this.runOnUiThread { Toast.makeText(this, getString(R.string.connection_avec_le_tag_perdue), Toast.LENGTH_SHORT).show() }

        // On désactive tous les boutons possibles
        switchButtons(false)

        // On change le texte du tableau du menu principal
        this.runOnUiThread {mainBinding.infoTagUID.text = getString(R.string.pas_de_tag)}
        this.runOnUiThread {mainBinding.infotagMoney.text = getString(R.string.pas_de_tag)}

        // On supprime le wrapper
        nfcWrapper = null
    }

    // ====================================== Lecture du dump ================================

    // Fonction qui lit le fichier dump, et l'affiche
    private fun readDump(uri : Uri) {
        Log.d("", uri.toString())
        try {
            val contenuDump = fileWrapper.lireFichier(uri)
            this.runOnUiThread {
                viewDumpBinding.lireDumpTitre.text = uri.path!!.toString().split("/").last()
            }
            this.runOnUiThread { viewDumpBinding.lireDumpContenu.text = contenuDump.uppercase() }
        } catch (e: Exception) {
            this.runOnUiThread {
                Toast.makeText(
                    this,
                    getString(R.string.erreur_lors_de_la_lecture_du_dump),
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    // Fonction qui lit un fichier de dump, et le transforme en template
    fun transformerTemplate(uri : Uri){
        // On ne va modifier que les lignes d'intérêt
        var contenu : MutableList<String>
        try {
            contenu = fileWrapper.lireFichier(uri).lines().toMutableList()
        }catch(e: IOException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_la_lecture_du_dump), Toast.LENGTH_SHORT).show() }
            return
        }

        // On doit modifier 3 choses : L'UID + BCC, et les deux soldes
        // 0e ligne UID BCC
        contenu[0] = "XXXXXXXXXX" + contenu[0].slice(10 until contenu[0].length)
        // 8 et 9e lignes ; Les différents soldes
        contenu[8] = contenu[8].slice(0..1) + "XXXXXX" + contenu[8].slice(8 until contenu[8].length)
        contenu[9] = contenu[9].slice(0..1) + "XXXXXX" + contenu[9].slice(8 until contenu[9].length)
        // Nom du fichier sui sera sauvegardé
        val fileName = uri.path!!.split("/").last().replace(".", "_template.")

        try{
            fileWrapper.ecrireFichier(contenu.joinToString(separator = "\n"), fileName)
        }catch (e : IOException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_l_criture_du_fichier), Toast.LENGTH_SHORT).show() }
            return
        }

        this.runOnUiThread { Toast.makeText(this, getString(R.string.template_sauvegard), Toast.LENGTH_SHORT).show() }
    }

    // ====================================== Dump du tag =======================================

    // Fonction qui appelle le dump de la clé, se charge des erreurs
    private fun dumpMizipTag(){

        var content = ""
        var cles : Pair<List<String>, List<String>>

        cles = utils.getAllKeys(nfcWrapper!!.getKeyUID())

        // On vérifie que le dump est ok, si non, on return
        try {
            content = nfcWrapper!!.dumpTag(cles.first)
        }catch (e : TagLostException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_tag_enleve), Toast.LENGTH_SHORT).show() }
            return
        }catch (e : IOException) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_de_communication), Toast.LENGTH_SHORT).show() }
            return
        }

        // Ecriture des infos dans le fichier
        try{
            // Formatage, et retour du dump
            content =  utils.traiterDump(content, cles.first, cles.second)
            fileWrapper.ecrireFichier(content, nfcWrapper!!.getKeyUID()+ ".txt")
        }catch(e : Exception){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_l_criture_du_fichier), Toast.LENGTH_SHORT).show() }
            return
        }

        this.runOnUiThread { Toast.makeText(this, getString(R.string.dump_effectue_fichier) + nfcWrapper?.getKeyUID()+ ".txt", Toast.LENGTH_SHORT).show()}
    }

    // ====================================== Ecriture nouveau tag ================================

    // S'occupe de la génération de l'UID, des clés, et du dump à écrire, puis l'écrit sur la clé
    fun ecrireNouveauTag(uid: String, solde: String, key : String, file : Uri) {

        // Verification de tout ce qui est entré
        if (! uid.matches(Regex(regexUIDRand))) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.param_tre_uid_invalide), Toast.LENGTH_SHORT).show() }
            return
        }
        // On vérifie si le solde est ok
        if (solde.isEmpty() || solde.toFloat() > 655.35){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.param_tre_solde_invalide), Toast.LENGTH_SHORT).show() }
            return
        }
        // On vérifie que la clé est Ok
        if (!key.matches(Regex(regexCle))){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.param_tre_cl_invalide), Toast.LENGTH_SHORT).show() }
        }

        // On génère l'UID + BCC
        val uidBcc = utils.generateUidBcc(uid)
        // On sépare l'UID pour le donner aux fonctions qui génèrent les clés
        val (listeKA, listeKB) = utils.getAllKeys(uidBcc.slice(0..7)).toList()

        var templateDump = ""
        try {
            // On récupère les infos du template
            templateDump = fileWrapper.lireFichier(file)
        }catch(e : IOException) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_la_lecture_du_template), Toast.LENGTH_SHORT).show() }
            return
        }

        //On récupère le solde voulu,et on calcule l'ancien, les deux bytes sont inversés pour chacun et on ca&lcule leur checksum
        val soldeActuel = utils.traiterSolde(solde)
        val ancienSolde = utils.traiterSolde((solde.toFloat() + 0.37).toString())

        // On génère ce que l'on va écrire dans la clé
        val contenu = utils.generateKeyContents(
            templateDump,
            listOf(uidBcc, ancienSolde, soldeActuel),
            listeKA,
            listeKB
        )

        // On écrit dans la clé
        try{
            nfcWrapper!!.writeWholeTag(contenu, List(5){ key }, List(5){key})
        } catch (e: IOException) {
            this.runOnUiThread { Toast.makeText(this, context.getString(R.string.erreur_lors_de_l_criture_sur_le_tag), Toast.LENGTH_LONG).show() }
            return
        } catch (e : TagLostException){
            this.runOnUiThread { Toast.makeText(this, context.getString(R.string.erreur_tag_enleve), Toast.LENGTH_LONG).show() }
            return
        }

        this.runOnUiThread {Toast.makeText(this, context.getString(R.string.cle_ecrite_avec_succes),Toast.LENGTH_LONG).show()}
    }

    // ====================================== Recharge tag =======================================

    // Fonction qui va servir à recharger la clé
    private fun rechargeTag(nouveauSolde : String){
        // On vérifie si le solde est ok
        if (nouveauSolde.isEmpty() || nouveauSolde.toFloat() > 655.35){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.param_tre_solde_invalide), Toast.LENGTH_SHORT).show() }
            return
        }

        // Vars pour le stockage du solde
        val ancienSolde : String
        val soldeActuel : String

        // On récupère l'UID
        val uid = nfcWrapper!!.getKeyUID()

        // On génère les clés A et B, et on récupère uniquemment celle qui nous intéresse : celle du secteur 2
        val cleA = utils.calcKey(uid, utils.baseKeyAList, utils::calcKeyA)[1]
        val cleB = utils.calcKey(uid, utils.baseKeyBList, utils::calcKeyB)[1]

        try {
            // On récupère seulement les deux lignes qui ont à voir avec le solde
            // Blocks 8 et 9 Secteur 2
            ancienSolde = nfcWrapper!!.readBlock(9, cleA, 2)
            soldeActuel = nfcWrapper!!.readBlock(8, cleA, 2)
        }catch(e : IOException) {
            this.runOnUiThread {Toast.makeText(context, getString(R.string.erreur_lors_de_la_lecture_du_solde_du_tag), Toast.LENGTH_LONG).show() }
            return
        }catch (e : TagLostException){
            this.runOnUiThread {Toast.makeText(context, getString(R.string.erreur_lors_de_la_lecture_du_solde_du_tag), Toast.LENGTH_LONG).show() }
            return
        }

        // On récupère le nouveau solde que l'on veut et son solde antérieur + leur checksum
        val nouveauSoldeAct = utils.traiterSolde(nouveauSolde)
        val nouveauSoldeAnt = utils.traiterSolde((nouveauSolde.toFloat() + 0.37).toString())

        // On remplace dans les deux lignes
        val ligneNouveauAnt = ancienSolde.replace(ancienSolde.slice(2..7), nouveauSoldeAnt)
        val ligneNouveauAct = soldeActuel.replace(soldeActuel.slice(2..7), nouveauSoldeAct)

        try{
            // On écrit les deux lignes
            nfcWrapper!!.writeBlock(ligneNouveauAnt, 2, 8, cleA, cleB)
            nfcWrapper!!.writeBlock(ligneNouveauAct, 2, 9, cleA, cleB)
        }catch(e : java.io.IOException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_l_criture_sur_le_tag), Toast.LENGTH_SHORT).show()}
            return
        }catch(e : TagLostException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_lors_de_l_criture_sur_le_tag), Toast.LENGTH_SHORT).show()}
            return
        }

        this.runOnUiThread { Toast.makeText(this, getString(R.string.cle_rechargee_avec_succes), Toast.LENGTH_SHORT).show()}
    }

    // ====================================== Change uid tag =======================================

    // Fonction qui change l'UID
    private fun changeUid(uid : String){

        // Verification de tout ce qui est entré
        if (! uid.matches(Regex(regexUIDRand))) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.param_tre_uid_invalide), Toast.LENGTH_SHORT).show() }
            return
        }

        // Récupération de toutes les clés
        var contenu : String
        // Nouvelles clés
        val newKeys = utils.getAllKeys(uid)
        // Anciennes clés (clés actuelles du tag)
        val oldKeys = utils.getAllKeys(nfcWrapper!!.getKeyUID())

        // Récupération et traitement du dump
        try{
            // Dump de l'ancienne clé
            contenu = nfcWrapper!!.dumpTag(oldKeys.first)
            // Modification des clés dans le dump, on met les nouvelles
            contenu = utils.traiterDump(contenu, newKeys.first, newKeys.second)
            // On remplace l'UID + BCC par les nouveaux
            contenu = utils.generateUidBcc(uid) + contenu.slice(10 until contenu.length)
            Log.d("", contenu)
        }catch (e : TagLostException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_tag_enleve), Toast.LENGTH_SHORT).show() }
            return
        }catch (e : IOException) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_de_communication), Toast.LENGTH_SHORT).show() }
            return
        }

        // Ecriture sur le tag des infos
        try{
            nfcWrapper!!.writeWholeTag(contenu, oldKeys.first, oldKeys.second)
        }catch (e : TagLostException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_tag_enleve), Toast.LENGTH_SHORT).show() }
            return
        }catch (e : IOException) {
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_de_communication), Toast.LENGTH_SHORT).show() }
            return
        }

        this.runOnUiThread { Toast.makeText(this, getString(R.string.uid_change_avec_succes), Toast.LENGTH_SHORT).show() }

    }

    // ====================================== Reset tag =======================================

    // Fonction qui reset la clé, On laisse son UID, mais on Passe toutes ses clés à FFFFFFFFFFFF
    private fun resetTag(){
        // On prend l'UID de la clé actuelle
        val uid = nfcWrapper!!.getKeyUID()
        try{
            // On récupère ses clés
            val (kA, kB) = utils.getAllKeys(uid).toList()
            // On écrit la clé de base, on catch les erreurs possibles
            nfcWrapper!!.writeWholeTag(baseCle, kA, kB)
        }catch(e : java.io.IOException){
            this.runOnUiThread {Toast.makeText(context, context.getString(R.string.erreur_lors_de_l_criture_sur_le_tag), Toast.LENGTH_LONG).show() }
            return
        }catch (e: TagLostException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.erreur_tag_enleve), Toast.LENGTH_SHORT).show() }
            return
        }
        this.runOnUiThread { Toast.makeText(this, getString(R.string.cle_reinitialisee_avec_succes), Toast.LENGTH_SHORT).show() }
    }

    // ====================================== Quelques fonctions ===================================

    // Fonction qui récupère le solde
    private fun getSolde() : String{
        // On prend la clé A du secteur 2
        val keyA = utils.getAllKeys(nfcWrapper!!.getKeyUID()).first[2]
        // On récupère les infos
        val solde = nfcWrapper!!.readBlock(9, keyA, 2)
        return solde.slice(2..5).chunked(2).reversed().joinToString(separator = "").toInt(16).div(100.0).toString()
    }

    // Une fonction qui appelle les différentes actions à effectuer, on l'utilise principalement pour
    // COuper le threadUpdate avant chaque opération sur le tag
    private fun launchAction(nb : Int, vararg args : String){
        // Stop le thread
        stopThreadUpdate()
        // On vérifie que le nfcWrapper est bien là
        nfcWrapper ?: return

        when (nb){
            2 -> dumpMizipTag()
            3 -> ecrireNouveauTag(args[0], args[1], args[2], args[3].toUri())
            4 -> rechargeTag(args[0])
            5 -> changeUid(args[0])
            6 -> resetTag()
        }
        // Redémerre le thread
        startThreadUpdate()
    }

    // ====================================== Ecrans des menus ===================================

    // Ecran du menu de lecture du dump
    private fun ecranLireDump(){
        setContentView(viewDumpBinding.root)

        // On récupère la liste des Uri des fichiers
        var listeUri = fileWrapper.listFiles().filter{!(it.toString().split("/").last() =="files")}

        // On setup le spin pour qu'il les affiche
        val adapter = ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, listeUri.map { it.toString().split("/").last() })
        viewDumpBinding.choixFichier.adapter = adapter

        // Lecture et affichage
        viewDumpBinding.lireDump.setOnClickListener { readDump(listeUri[viewDumpBinding.choixFichier.selectedItemPosition]) }

        // Transformation en Template
        viewDumpBinding.makeTemplate.setOnClickListener {
            transformerTemplate(listeUri[viewDumpBinding.choixFichier.selectedItemPosition])
            // On recharge la liste des fichiers
            listeUri = fileWrapper.listFiles()
            adapter.clear()
            adapter.addAll(listeUri.map { it.toString().split("/").last() }.filter{it != "files"})
        }


    }

    // Ecran du menu écrire une nouvelle clé
    private fun ecranEcrireNouvelleCle(){

        // On récupère la liste des Uri des fichiers
        var listeUri = fileWrapper.listFiles().filter { it.path.toString().contains("template") }

        // On setup le spin pour qu'il les affiche
        val adapter = ArrayAdapter<String>(this, android.R.layout.simple_spinner_dropdown_item, listeUri.map { it.toString().split("/").last() })
        writeNewBinding.choixFichierNew.adapter = adapter

        setContentView(writeNewBinding.root)

        try {
            writeNewBinding.writeNewKey.setOnClickListener {launchAction(3, writeNewBinding.uidBase.text.toString(),
                writeNewBinding.nouveauSolde.text.toString(),
                writeNewBinding.bKey.text.toString(),
                listeUri[writeNewBinding.choixFichierNew.selectedItemPosition].toString()) }
        }catch(e : ArrayIndexOutOfBoundsException){
            this.runOnUiThread { Toast.makeText(this, getString(R.string.pas_de_template_s_lectionn), Toast.LENGTH_SHORT).show() }
        }

    }

    // Ecran du menu de recharge
    private fun ecranRechargerCle(){
        setContentView(rechargeBinding.root)
        rechargeBinding.buttonRecharge.setOnClickListener { launchAction(4, rechargeBinding.nouveauSoldeRecharge.text.toString()) }
    }

    // Ecran du menu de changement d'UID
    private fun ecranChangeId(){
        setContentView(changeIdBinding.root)
        changeIdBinding.buttonChId.setOnClickListener { launchAction(5, changeIdBinding.nouveauUid.text.toString()) }
    }


    // ====================================== Les méthodes de base ================================

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Context
        context = applicationContext

        fileWrapper = FileWrapper(context)

        mainBinding = ActivityMainScreenBinding.inflate(layoutInflater)
        writeNewBinding = ActivityWriteNewBinding.inflate(layoutInflater)
        rechargeBinding = ActivityRechargeKeyBinding.inflate(layoutInflater)
        changeIdBinding = ActivityChangeIdBinding.inflate(layoutInflater)
        viewDumpBinding = ActivityViewDumpBinding.inflate(layoutInflater)

        setContentView(mainBinding.root)

        mainBinding.boutonLireDump.setOnClickListener { ecranLireDump() }
        mainBinding.dumpKey.setOnClickListener { launchAction(2) }
        mainBinding.writeNewKey.setOnClickListener { ecranEcrireNouvelleCle() }
        mainBinding.rechargeKey.setOnClickListener { ecranRechargerCle() }
        mainBinding.changeUid.setOnClickListener { ecranChangeId() }
        mainBinding.activateReset.setOnClickListener {mainBinding.resetKey.isEnabled = mainBinding.activateReset.isChecked }
        mainBinding.resetKey.setOnClickListener { launchAction(6) }
    }

    override fun onStart() {
        super.onStart()
        // Some setup for NFC stuff
        val nfcAdapter = getDefaultAdapter(context)
        nfcAdapter.enableReaderMode(this,
            { tag -> connectToTag(tag) }, NfcAdapter.FLAG_READER_NFC_A , null)
    }

    override fun onBackPressed() {
        // A messay way of implementing the back button feature
        setContentView(mainBinding.root)
    }

    override fun onStop() {
        super.onStop()
        getDefaultAdapter(context).disableReaderMode(this)
    }

}
