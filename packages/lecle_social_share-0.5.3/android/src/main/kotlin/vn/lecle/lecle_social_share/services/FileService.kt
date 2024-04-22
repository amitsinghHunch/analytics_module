package vn.lecle.lecle_social_share.services

import java.io.*
import java.nio.channels.FileChannel

object FileService {
    @Throws(IOException::class)
    fun exportFile(src: File, dst: File): File? {
        if (!dst.exists()) {
            if (!dst.mkdir()) {
                return null
            }
        }
        val expFile =
            File(dst.path + File.separator + "Temp_" + src.name)
        var inChannel: FileChannel? = null
        var outChannel: FileChannel? = null
        try {
            inChannel = FileInputStream(src).channel
            outChannel = FileOutputStream(expFile).channel
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        }
        try {
            inChannel?.transferTo(0, inChannel.size(), outChannel)
        } finally {
            inChannel?.close()
            outChannel?.close()
        }
        return expFile
    }

    fun resolveFileType(type: String): String {
        return when (type) {
            "video" -> {
                "video/*"
            }
            "image" -> {
                "image/*"
            }
            "audio" -> {
                "audio/*"
            }
            else -> {
                "*/*"
            }
        }
    }
}