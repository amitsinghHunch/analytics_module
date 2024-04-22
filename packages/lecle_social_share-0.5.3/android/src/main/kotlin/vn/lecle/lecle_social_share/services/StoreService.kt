package vn.lecle.lecle_social_share.services

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri

object StoreService {
    fun isPackageInstalled(context: Context, appPackageName: String): Boolean {
        return try {
            val packageManager = context.packageManager
            packageManager.getPackageInfo(appPackageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    fun openAppOnStore(context: Context, appPackageName: String) {
        val i = Intent(Intent.ACTION_VIEW)

        i.data =
            Uri.parse("https://play.google.com/store/apps/details?id=$appPackageName")
        context.startActivity(i)
    }
}