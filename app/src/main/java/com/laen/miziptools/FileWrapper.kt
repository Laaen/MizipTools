package com.laen.miziptools

import android.content.Context
import android.net.Uri
import androidx.core.net.toUri
import java.io.BufferedReader
import java.io.File
import java.io.InputStream
import java.io.InputStreamReader
import java.util.Locale

class FileWrapper(private val context: Context) {

    // Fonction qui liste les fichiers présents dans le répertoire de l'appli
    fun listFiles() : List<Uri>{
        val path = context.getExternalFilesDir(null)
        return File(path, "").walkBottomUp().map { it.toUri() }.toList()
    }

    // Fonction qui lit le contenu du fichier de dump
    fun lireFichier(uri: Uri): String {
        val stringBuilder = StringBuilder()
        context.contentResolver.openInputStream(uri)?.use { inputStream: InputStream ->
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

    // Fonction qui écrit le contenu donné dans le fichier
    fun ecrireFichier(infos : String?, nomFichier : String){
        // Vérification que les infos sont ok
        infos ?: return
        val path = context.getExternalFilesDir(null)
        val file = File(path, nomFichier)
        // On efface les infos du fichier avant de l'écrire
        file.delete()
        file.appendText(infos.uppercase(Locale("EN")))
    }

    // Fonction qui supprime le fichier
    fun deleteFile(uri : Uri){
        File(uri.path!!).delete()
    }

}