package com.laen.miziptools

import android.nfc.tech.MifareClassic
import java.util.Locale

// Classe qui gère tout ce qui est interactions avec le tag NFC
class NFCWrapper (private val nfc: MifareClassic) {
    init{
        nfc.connect()
    }

    // Lit un block de données à l'aide de la clé donnée
    fun readBlock(block : Int, key : String, sector : Int): String{
        val cle = convertToByteArr(key)
        nfc.authenticateSectorWithKeyA(sector, cle)
        return nfc.readBlock(block)
            .joinToString(separator = "") { it.toUByte().toString(16).padStart(2, '0') }
            .padStart(32, '0')
    }

    fun writeBlock(content : String, sector : Int, block : Int, key_a : String, key_b : String ) : Boolean{
        // Si le contenu est un multiple de 2
        try {
            if (content.length % 2 == 0) {
                nfc.authenticateSectorWithKeyA(sector, convertToByteArr(key_a))
                nfc.authenticateSectorWithKeyB(sector, convertToByteArr(key_b))
                nfc.writeBlock(
                    block,
                    content.chunked(2).map { it.toUByte(radix = 16).toByte() }.toByteArray()
                )
                return true
            } else {
                return false
            }
        }catch (e : android.nfc.TagLostException){
            throw android.nfc.TagLostException("Tag lost")
        }

    }

    // Dumpe le contenu de la clé, renvoir un string
    fun dumpTag(keysA : List<String>) : String{
        var contenuDump = ""
        try {
            for (i in 0..19) {
                contenuDump += readBlock(i,keysA[i / 4], i / 4) + "\n"
            }
        }catch (e : android.nfc.TagLostException){
            throw e
        }catch (e : java.io.IOException){
            throw e
        }

        return contenuDump
    }

    // Prend un dump de tout le tag, et l'écrit
    fun writeWholeTag(contenu : String, keysA : List<String>, keysB : List<String>){ // Pour les 20 secteurs
        try{
            for (i in 0..19) {
                // On Ecrit
                this.writeBlock(contenu.lines()[i], i / 4, i, keysA[i / 4], keysB[i / 4])
            }
        }catch (e : android.nfc.TagLostException){
            throw e
        }catch (e : java.io.IOException){
            throw e
        }
    }

    fun getKeyUID() : String = nfc.tag.id.joinToString(separator = "") { it.toUByte().toString(radix = 16).padStart(2, '0') }.uppercase(
        Locale("EN"))

    // Convertit un String en ByteArray
    private fun convertToByteArr(key : String): ByteArray{
        //On iitère sur des groupes de deux chars, pour chacun on le convertit en byte, et on l'ajoute à la liste
        return key.chunked(2).map { it.toUByte(radix = 16).toByte() }.toByteArray()
    }

}

