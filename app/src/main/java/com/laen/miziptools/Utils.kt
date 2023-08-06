package com.laen.miziptools

/*
    Cette classe regroupe toutes les fonctions qui sont utilisées un peu
    partout (ex traiterDump, traiterSolde ...)
 */

class Utils {

    // CLés et UID connus à partir desquels on va calculer les clés du MiZip
    val baseKeyAList = listOf("6421E1E7E4D6", "C64672F5FF1C", "8F41FA6D413A", "5C490CED29A3")
    val baseKeyBList = listOf("4AEEE96063E3", "C825F4CD8983", "118F7E45ED6C", "0BD14A14963F")
    private val baseUid = "6D33BBC2"

    //Caractères possibles pour du hexa
    private val charsPossibles = "ABCDEF0123456789"

    fun generateKeyContents(
        content: String,
        listeRempl: List<String>,
        listeKA: List<String>,
        listeKB: List<String>
    ): String {
        // On génère le contenu de la clé, on prend comme base un contenu (5 Secteurs de 4 blocks)
        // On travaille block par block, Pour chaque block, on remplace d'éventuels X par les valeurs données dans la liste
        // A chaque 4e block, on entre les clés données en args
        var resultat = ""
        var indexListeRempl = 0
        var indexSubListe = 0
        var ligneModifiee = false
        var numeroLigne = 1

        try {
            for (ligne in content.lines()) {
                // Si c'est quatrième ligne, on se contente d'entrer les clés
                if (numeroLigne % 4 == 0) {
                    resultat += listeKA[numeroLigne / 4 - 1] + ligne.slice(12..19) + listeKB[numeroLigne / 4 - 1]
                    resultat += '\n'
                    numeroLigne += 1
                    continue
                }
                for (char in ligne) {
                    when (char) {
                        'X' -> {
                            resultat += listeRempl[indexListeRempl][indexSubListe]
                            indexSubListe += 1
                            ligneModifiee = true
                        }
                        'Y' -> {
                            // Remplacement d'un "Y" par un caractère aléatoire
                            resultat += charsPossibles.random()
                        }
                        else -> {
                            resultat += char
                        }
                    }
                }
                if (ligneModifiee) {
                    indexListeRempl += 1
                    indexSubListe = 0
                    ligneModifiee = false
                }
                resultat += '\n'
                numeroLigne += 1

            }
        } catch (e: IndexOutOfBoundsException) {
            throw Exception("Erreur d'index, soit la liste donnée en paramètre n'a pas assez de strings, soit un des string à l'intérieur n'est pas assez long")
        }

        return resultat
    }

    // On génère un uid + bcc à partir de la base donnée
    fun generateUidBcc(uid: String): String {
        // uid => Base que l'on veut XXXXXXXX => Que des bytes aléatoires | BXAXXXXX => UID qui contiendra les bits donnés (ex BDAF78F1)
        // On va map pour chaque char du str un nouveau char si c'est X
        val uidRand = uid.map { if (it != 'X') it else charsPossibles.random() }.joinToString(separator = "")
        // Avec l'UID, on va générer le BCC (le checksum)
        // C'est juste un XOR sur chaque Byte consécutif
        val bcc =
            uidRand.chunked(2).map { it.toLong(radix = 16) }.reduce { curr, next -> curr xor next }
                .toString(radix = 16).padStart(2, '0')
        return (uidRand + bcc)
    }


    // Ajoute les clés à la fin des blocks dans le dump
    fun traiterDump(dump : String, lKeyA : List<String>, lKeyB : List<String>) : String{

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

    // Renvoie un solde en Hexa inversé avec son Checksum à partir d'un solde String au format FLoat
    fun traiterSolde(solde: String): String {
        val resultat =
            (solde.toFloat() * 100).toInt().toString(radix = 16).padStart(4, '0').chunked(2)
                .reversed().joinToString(separator = "")
        return resultat + resultat.chunked(2).map { it.toLong(radix = 16) }
            .reduce { curr, next -> curr xor next }.toString(radix = 16).padStart(2, '0')
    }

    // Fonctions qui permettent de calculer les clés A et B
    fun calcKeyA(uid : String) = (uid + uid.slice(0..3))
    fun calcKeyB(uid : String) = (uid.slice(4..7) + uid)

    fun calcKey(target_uid : String,  keys_list : List<String>, generatingFunc : (String) -> String): List<String>
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

}