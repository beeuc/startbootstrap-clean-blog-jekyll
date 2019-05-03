---
title: How to upload macos App for notarization by command-line tools
layout: post
date: 2019-04-12
category: App-development
subtitle: As required by Apple recently, macos App developers need to upload the Apps they developed to Apple for a notarization.

---

# How to upload macos App for notarization by command-line tools

As required by Apple below recently, macos App developers need to upload the Apps they developed to Apple for a notarization before distributing the Apps. 



> With the public release of macOS 10.14.5, we require that all developers creating a Developer ID certificate for the first time notarize their apps, and that all new and updated kernel extensions be notarized as well. This will help give users more confidence that the software they download and run, no matter where they get it from, is not malware by showing a more streamlined Gatekeeper interface. In addition, we’ve made the following enhancements to the notarization process.

Refer to [Notarizing Your App Before Distribution](https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution) for more background. 

## How to

To integrate the notarization steps into the CI system, we added the following steps in our automation build scripts.

### Upload the App archive 


```shell
APP_PATH="./${PRODUCT_NAME}.app"
ZIP_PATH="./${PRODUCT_NAME}.zip"
ls

```

`APP_PATH="./${PRODUCT_NAME}.app"`
`ZIP_PATH="./${PRODUCT_NAME}.zip"`

`/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"`

`xcrun altool --notarize-app --primary-bundle-id ${BUNDLE_IDENTIFIER} -u ${APP_ACCOUNT} -p ${APP_SPEC_PASSWD} --asc-provider "${DEVELOPMENT_TEAM}" --file ${ZIP_PATH}`


The `--asc-provider` parameter is needed for us as our App management account is being used by more than one orgnizations. Otherwise the `--notarize-app` command would fail with the following error prompt message. 


> Error: Your Apple ID account is attached to other iTunes providers. You will need to specify which provider you intend to submit content to by using the -itc_provider command. Please contact us if you have questions or need help. (1627)

> However, we didn't find how -itc_provider can be specified, but found the —asc-provider parameter. Maybe the prompt itself is a mistake.

Apple's official documentation states that the notarization could complete in about 1 hour. We found it usually complete in several minutes and we would receive the email notification shortly after we have had the archive uploaded.

### Upload the installer package



`xcrun altool --notarize-app --primary-bundle-id ${BUNDLE_IDENTIFIER} -u ${APP_ACCOUNT} -p ${APP_SPEC_PASSWD} --asc-provider "${DEVELOPMENT_TEAM}" --file ${WORKSPACE}/${RELEASE_PKG_NAME}`

> Be sure to use --timestamp paramether w/ the productsign command when signing the installer package file. Otherwise the notarization could fail due to the issue that the signature doesn't contain a valid timestamp. 

Refer to [Resolving common notarization issues](https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/resolving_common_notarization_issues).

### Check the notarization result

Once received the email notification of the completion of the notarization, you'd better check the notarization log  even it's a successful result as suggested by Apple. 

To obtain detailed information about a particular submission, use `altool` along with the `notarization-info` flag and the UUID for the submission. The UUID is printed when the `altool —notarize-app` command finished. For more details about how to check the status and log, refer to [Customizing the notarization workflow]( https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/customizing_the_notarization_workflow#3087732 ). 

### Staple your App and the installer package

Notarization produces a ticket that tells Gatekeeper that your app is notarized. After notarization completes successfully, the next time any user attempts to run your app on macOS 10.14 or later, Gatekeeper finds the ticket online. This includes users who downloaded your app before notarization. You should also attach the ticket to your software using the `stapler` tool, so that future distributions include the ticket. This ensures that Gatekeeper can find the ticket even when a network connection isn’t available. 

For the details about how to staple the files, refer to [Customizing the notarization workflow]( https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/customizing_the_notarization_workflow#3087732 ) too. 

## References

- [Notarizing Your App Before Distribution](https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution) 
- [Resolving common notarization issues]( https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/resolving_common_notarization_issues)
- [Customizing the notarization workflow]( https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/customizing_the_notarization_workflow#3087732 )
