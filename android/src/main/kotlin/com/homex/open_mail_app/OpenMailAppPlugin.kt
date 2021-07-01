package com.homex.open_mail_app

import android.content.Context
import android.content.Intent
import android.content.pm.LabeledIntent
import android.net.Uri
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class OpenMailAppPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Although getFlutterEngine is deprecated we still need to use it for
        // apps not updated to Flutter Android v2 embedding
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "open_mail_app")
        channel.setMethodCallHandler(this)
        init(flutterPluginBinding.applicationContext)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "open_mail_app")
            val plugin = OpenMailAppPlugin()
            channel.setMethodCallHandler(plugin)
            plugin.init(registrar.context())
        }
    }

    fun init(context: Context) {
        applicationContext = context
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "openMailApp") {
            val opened = emailAppIntent(call.argument("nativePickerTitle") ?: "")
            if (opened) {
                result.success(true)
            } else {
                result.success(false)
            }
        } else if (call.method == "openSpecificMailApp" && call.hasArgument("name")) {
            val opened = specificEmailAppIntent(call.argument("name")!!)
            if (opened) {
                result.success(true)
            } else {
                result.success(false)
            }
        } else if (call.method == "composeNewEmailInMailApp") {
            val opened = composeNewEmailAppIntent(call.argument("nativePickerTitle") ?: "", call.argument("emailContent"))
            if (opened) {
                result.success(true)
            } else {
                result.success(false)
            }
        } else if (call.method == "composeNewEmailInSpecificMailApp") {
            val openend = composeNewEmailInSpecificEmailAppIntent(call.argument("name"), call.argument("emailContent"))
            if (opened) {
                result.success(true);
            } else {
                result.succes(false);
            }
        } else if (call.method == "getMainApps") {
            val apps = getInstalledMailApps()
            val appsJson = Gson().toJson(apps)
            result.success(appsJson)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun emailAppIntent(@NonNull chooserTitle: String): Boolean {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        if (activitiesHandlingEmails.isNotEmpty()) {
            // use the first email package to create the chooserIntent
            val firstEmailPackageName = activitiesHandlingEmails.first().activityInfo.packageName
            val firstEmailInboxIntent = packageManager.getLaunchIntentForPackage(firstEmailPackageName)
            val emailAppChooserIntent = Intent.createChooser(firstEmailInboxIntent, chooserTitle)

            // created UI for other email packages and add them to the chooser
            val emailInboxIntents = mutableListOf<LabeledIntent>()
            for (i in 1 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                val packageName = activityHandlingEmail.activityInfo.packageName
                packageManager.getLaunchIntentForPackage(packageName)?.let { intent ->
                    emailInboxIntents.add(
                            LabeledIntent(
                                    intent,
                                    packageName,
                                    activityHandlingEmail.loadLabel(packageManager),
                                    activityHandlingEmail.icon
                            )
                    )
                }
            }
            val extraEmailInboxIntents = emailInboxIntents.toTypedArray()
            val finalIntent = emailAppChooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraEmailInboxIntents)
            finalIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            applicationContext.startActivity(finalIntent)
            return true
        } else {
            return false
        }
    }

    private fun composeNewEmailAppIntent(@NonNull chooserTitle: String, @NonNull contentJson: string): Boolean {
        val packageManager = applicationContext.packageManager
        val emailContent = Gson().fromJson(contentJson, EmailContent::class.java)
        val emailIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:")
            putExtra(Intent.EXTRA_EMAIL, emailContent.to)
            putExtra(Intent.EXTRA_CC, emailContent.cc)
            putExtra(Intent.EXTRA_BCC, emailContent.bcc)
            putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
            putExtra(Intent.EXTRA_TEXT, emailContent.body)
        }

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        if (activitiesHandlingEmails.isNotEmpty()) {
            val firstEmailPackageName = activitiesHandlingEmails.first().activityInfo.packageName
            val firstEmailComposeIntent = packageManager.getLaunchIntentForPackage(firstEmailPackageName)
            val emailAppChooserIntent = Intent.createChooser(firstEmailComposeIntent, chooserTitle)

            val emailComposingIntents = mutableListOf<LabeledIntent>()
            for (i in 1 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                val packageName = activityHandlingEmail.activityInfo.packageName
                packageManager.getLaunchIntentForPackage(packageName)?.let { intent ->
                    emailComposingIntents.add(
                        intent.putExtra(Intent.EXTRA_EMAIL, emailContent.to)
                        intent.putExtra(Intent.EXTRA_CC, emailContent.cc)
                        intent.putExtra(Intent.EXTRA_BCC, emailContent.bcc)
                        intent.putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
                        intent.putExtra(Intent.EXTRA_TEXT, emailContent.body)
                        LabeledIntent(
                            intent  
                            packageName, 
                            activityHandlingEmail.loadLabel(packageManager),
                            activityHandlingEmail.icon
                        ), 
                    )
                }
            }

            val extraEmailComposingIntents = mutableListOf<LabeledIntent>()
            val finalIntent = emailAppChooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraEmailInboxIntents)
            finalIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            applicationContext.startActivity(finalIntent)
            return true;
        } else {
            return false
        }
    }

    private fun specificEmailAppIntent(name: String): Boolean {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        val activityHandlingEmail = activitiesHandlingEmails.firstOrNull {
            it.loadLabel(packageManager) == name
        } ?: return false

        val firstEmailPackageName = activityHandlingEmail.activityInfo.packageName
        val emailInboxIntent = packageManager.getLaunchIntentForPackage(firstEmailPackageName)
                ?: return false

        emailInboxIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        applicationContext.startActivity(emailInboxIntent)
        return true
    }

    private fun composeNewEmailInSpecificEmailAppIntent(@NonNull name: String, @NonNull contentJson: String): Boolean {
        val packageManager = applicationContext.packageManager
        val emailContent = Gson().fromJson(contentJson, EmailContent::class.java)
        val emailIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:")
            putExtra(Intent.EXTRA_EMAIL, emailContent.to)
            putExtra(Intent.EXTRA_CC, emailContent.cc)
            putExtra(Intent.EXTRA_BCC, emailContent.bcc)
            putExtra(Intent.EXTRA_SUBJECT, emailContent.subject)
            putExtra(Intent.EXTRA_TEXT, emailContent.body)
        }

        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)
        val specificEmailActivity = activitiesHandlingEmails.firstOrNull {
            it.loadLabel(packageManager) == name
        } ?: return false

        val specificEmailActivityPackageName = specificEmailActivity.activityInfo.packageName
        val composeEmailIntent = packageManager.getLaunchIntentForPackage(specificEmailActivityPackageName) ?: return false

        composeEmailIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        applicationContext.startActivity(composeEmailIntent)
        return true

        return true;
    }

    private fun getInstalledMailApps(): List<App> {
        val emailIntent = Intent(Intent.ACTION_VIEW, Uri.parse("mailto:"))
        val packageManager = applicationContext.packageManager
        val activitiesHandlingEmails = packageManager.queryIntentActivities(emailIntent, 0)

        return if (activitiesHandlingEmails.isNotEmpty()) {
            val mailApps = mutableListOf<App>()
            for (i in 0 until activitiesHandlingEmails.size) {
                val activityHandlingEmail = activitiesHandlingEmails[i]
                mailApps.add(App(activityHandlingEmail.loadLabel(packageManager).toString()))
            }
            mailApps
        } else {
            emptyList()
        }
    }
}

data class App(
        @SerializedName("name") val name: String
)

data class EmailContent {
    val to: List<String>
    val cc: List<String>
    val bcc: List<String>
    val subject: String
    val body: String
}