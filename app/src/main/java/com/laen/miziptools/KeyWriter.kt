package com.laen.miziptools

import android.content.Context
import android.net.Uri
import android.util.Log
import android.widget.Toast
import com.example.miziptools.R
import java.io.BufferedReader
import java.io.FileNotFoundException
import java.io.InputStream
import java.io.InputStreamReader


// Classe qui gère l'écriture sur la clé
class KeyWriter constructor(private val root : MainActivity){

    //Caractères possibles pour du hexa
    private val charsPossibles = "ABCDEF0123456789"

    // Valeur déduite du solde actuel (car la clé stocke ancien solde et nouveau solde
    private val deduction = 0.37

    fun generateUidBcc(uid : String): String{
        // On génère un uid + bcc à partir de la base donnée
        // uid => Base que l'on veut XXXXXXXX => Que des bytes aléatoires | BXAXXXXX => UID qui contiendra les bits donnés (ex BDAF78F1)
        var uid = if(uid.length == 8) uid else "XXXXXXXX"
        // On va map pour chaque char du str un nouveau char si c'est X
        uid = uid.map{if(it != 'X') it else charsPossibles.random()}.joinToString(separator = "")
        // Avec l'UID, on va générer le BCC (le checksum)
        // C'est juste un XOR sur chaque Byte consécutif
        val bcc = uid.chunked(2).map{it.toLong(radix = 16)}.reduce{curr, next -> curr xor next}.toString(radix = 16).padStart(2, '0')
        return (uid + bcc)
    }

    private fun generateKeyContents(content : String, listeRempl : List<String>, listeKA : List<String>, listeKB : List<String>): String{
        // On génère le contenu de la clé, on prend comme base un contenu (5 Secteurs de 4 blocks)
        // On travaille block par block, Pour chaque block, on remplace d'éventuels X par les valeurs données dans la liste
        // A chaque 4e block, on entre les clés données en args
        var resultat = ""
        var indexListeRempl = 0
        var indexSubListe = 0
        var ligneModifiee = false
        var numeroLigne = 1

        try{
            for (ligne in content.lines()){
                // Si c'est quatrième ligne, on se contente d'entrer les clés
                if (numeroLigne % 4 == 0){
                    resultat += listeKA[numeroLigne/4 -1] + ligne.slice(12..19) + listeKB[numeroLigne/4 -1 ]
                    resultat += '\n'
                    numeroLigne += 1
                    continue
                }
                for (char in ligne){
                    if(char == 'X'){
                        resultat += listeRempl[indexListeRempl][indexSubListe]
                        indexSubListe += 1
                        ligneModifiee = true
                    }else{
                        resultat += char
                    }
                }
                if (ligneModifiee){
                    indexListeRempl += 1
                    indexSubListe = 0
                    ligneModifiee = false
                }
                resultat += '\n'
                numeroLigne += 1

            }
        }catch(e : IndexOutOfBoundsException){
            throw Exception("Erreur d'index, soit la liste donnée en paramètre n'a pas assez de strings, soit un des string à l'intérieur n'est pas assez long")
        }

        return resultat
    }

    // Renvoie un solde en Hexa inversé avec son Checksum à partir d'un solde String au format FLoat
    fun traiterSolde(solde : String) : String{
        val resultat = (solde.toFloat() * 100).toInt().toString(radix = 16).padStart(4, '0').chunked(2).reversed().joinToString(separator = "")
        return resultat + resultat.chunked(2).map { it.toLong(radix = 16) }.reduce{curr, next -> curr xor next}.toString(radix = 16).padStart(2, '0')
    }


    // S'occupe de la génération de l'UID, des clés, et du dump à écrire, puis l'écrit sur la clé
    fun ecrireNouvelleCle(uid : String, solde : String){

        // On génère l'UID + BCC
        val uidBcc = generateUidBcc(uid)
        Log.d("Info", uidBcc)
        Log.d("UID", uidBcc.slice(0..7))
        // On sépare l'UID pour le donner aux fonctions qui génèrent les clés
        val (listeKA, listeKB) = root.getAllKeys(uidBcc.slice(0..7)).toList()
        listeKA.map{println(it)}

        try{
            // On récupère les infos du dump
            val templateDump = lireFichier(root.uriFichier!!)
            //On récupère le solde voulu,et on calcule l'ancien, les deux bytes sont inversés pour chacun et on ca&lcule leur checksum
            val soldeActuel  = traiterSolde(solde)
            val ancienSolde = traiterSolde((solde.toFloat() + deduction).toString())
            // On génère ce que l'on va écrire dans la clé
            val contenu = generateKeyContents(templateDump, listOf(uidBcc, ancienSolde, soldeActuel), listeKA, listeKB)
            // On écrit dans la clé
            ecritureCleUnique(contenu, root.writeNewBinding.bKey.text.toString())
        }catch(e : FileNotFoundException){
            Log.e("Fichier", "Erreur lors de la lecture du fichier : ${e.message}")
        }catch (e : java.lang.Exception) {
            Log.e("Erreur", "Erreur : $e")
        }

        Toast.makeText(this.root, root.context.getString(R.string.cle_ecrite_avec_succes), Toast.LENGTH_LONG).show()
    }

    // Fonction qui lit le contenu du fichier de dump
    private fun lireFichier(uri: Uri): String {
        val stringBuilder = StringBuilder()
        root.contentResolver.openInputStream(uri)?.use { inputStream : InputStream ->
            BufferedReader(InputStreamReader(inputStream)).use { reader ->
                var line: String? = reader.readLine()
                while (line != null) {
                    stringBuilder.append(line)
                    line = reader.readLine()
                    stringBuilder.append('\n')
                }
            }
        }
        return stringBuilder.toString()
    }

    // Fonction qui permet de choisir un fichier
    fun choisirFichier(){
        root.dirRequest.launch(arrayOf("*/*"))
    }

    // FOnction qui écrit le contenu dans la clé
    fun ecritureCle(contenu : String, l_k_a: List<String>, l_k_b : List<String>){
        // Pour les 20 secteurs
        for (i in 0..19){
            // On Ecrit
            root.nfcWrapper.writeBlock(contenu.lines()[i],i/4, i, l_k_a[i/4], l_k_b[i/4])
        }
    }

    // Fonction qui écrit le contenu dans la clé, en se basant sur la clé donnée (Correspond aux clée A et B de tous les secteurs)
    private fun ecritureCleUnique(contenu : String, cle : String){
        // Pour les 20 secteurs
        for (i in 0..19){
            // On Ecrit
            root.nfcWrapper.writeBlock(contenu.lines()[i],i/4, i, cle, cle)
        }
    }
}