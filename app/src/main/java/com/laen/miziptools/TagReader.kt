package com.laen.miziptools

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.widget.EditText
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat.startActivityForResult
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader

class TagReader constructor(private val root : MainActivity){

    // Var qui contient l'uri
    private var uriFichier : Uri = Uri.parse("")

    private val dirRequestWriteKey = root.registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        uri?.let {
            // call this to persist permission across decice reboots
            root.contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            // do your stuff
            this.uriFichier = uri
        }
    }

    // Choix du fichier, on prend en paramètre un editText pour pouvoir modifier sa valeur
    fun choisirFichier(){
        // On récupère l'Uri
        dirRequestWriteKey.launch(arrayOf("*/*"))
    }

    fun getUriFichier() : Uri {
        return uriFichier
    }

    // Fonction qui lit le contenu du fichier de dump
    fun lireFichier(uri: Uri): String {
        val stringBuilder = StringBuilder()
        root.contentResolver.openInputStream(uri)?.use { inputStream: InputStream ->
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



}