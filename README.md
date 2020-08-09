![](https://img.shields.io/github/license/srea/RIBsTreeViewerClient.svg) 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
# RIBsTreeViewer

![](./docs/logo.png)  

Real Time viewing attached RIBs Tree on Browser

## Demo

![](./docs/demo.gif)  

## Using the Libraries

### Swift Package Manager
From Xcode 11, you can use `Swift Package Manager` to add Kingfisher to your project.

Select File > Swift Packages > Add Package Dependency. Enter https://github.com/dangthaison91/RIBsTree.git in the "Choose Package Repository" dialog.
In the next page, specify the version resolving rule as "branch" with "master" as its earliest version.
After Xcode checking out the source and resolving the version, you can choose the "RIBsTree" library and add it to your app target.


## Basic setup

```swift
import RIBsTree

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let result = RootBuilder(dependency: AppComponent()).build()
        let launchRouter = result.launchRouter
        self.launchRouter = launchRouter
        urlHandler = result.urlHandler
        launchRouter.launch(from: window)

        #if DEBUG
        RIBsTreeViewer().start(from: launchRouter)
        #endif

        return true
    }
}
```

## Installing 

### Starting the websocket server

```shell
$ cd WebSocketServer
$ npm install
$ node index.js
```

## Open the page.

```shell
$ cd Browser
$ npm install
$ npm start
open localhost:8088 in Chrome/Safari browser
```