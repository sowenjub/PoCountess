# PoCountess

**PoCountess is a macOS app to track your https://countapi.xyz counters.**

You can:
* track/create multiple namespaces
* track/create/increment multiple keys per namespace

PoCountess stands for Proof of Countess, because this app is a proof of concept macOS app built for [SwiftUI Series 2022](https://www.swiftuiseries.com/).
This PoC should turn into [@CountessApp](https://twitter.com/CountessApp), which will be available on iOS/iPadOS and have a broader scope of features (follow to join the Testflight).

Why Countess? Because the app has many counters that report the latest gossip from a domain with diligence.

You will interact with:
* *Domains*, consisting of:
    * a namespace (used by [Countapi](https://countapi.xyz)), 
    * a title (a human readable name),
    * and Counters
* *Counters*, consisting of:
    * a key (used by [Countapi](https://countapi.xyz))
    * a title (a human readable name)

# Features

* Create or track existing countapi.xyz namespaces
* Create or track existing countapi.xyz keys
* Increment countapi.xyz counters
* Lock Counters to prevent unintential update from the app (default when creating)

# Taking a quick tour with the Countess

* Launch her (not too high)
* Click "Go Mingle" at the bottom of the welcome screen
* Look at the Counters, they all serve a different purpose
* Check the menu bar for a quick look at your keys

## Menu/Commands

* ⌘D to create a new domain with counters
* ⌘R to refresh all the counters in the current view
* Toggle the sidebar:
    * from "View > Show/Hide Sidebar"
    * with ⌃⌘S
    * from the icon in the toolbar

## AccentColor

The app uses an accentColor defined in its Assets.

## Domains

* Adding a domain
    * Adding a new domain will automatically focus on its namespace for rapid editing
    * If you select a different domain and come back to it, it won't re-focus (cause that would be pretty annoying)
* Deleting a domain
    * press the delete key when selecting it
    * right click on it

Deleting a domain will present the Welcome view again, which is weirdly hard to get right.

## Other things to notice

* Groundwork for Localization
* Use of accessibility Labels

# Known issues & limitations

* If you delete the last but one domain, the WelcomeView() is shown instead of the last domain.
* Deleting a key will delete the whole domain.
* No proper management of windows/tabs (switching namespace in one window switches everywhere)

# Questions I'm left with

* How to fix the know issues 😂
* How to have clear backgrounds for textfields
* How to change the Counters List background
* Windows & Tabs management

# Let's keep in touch

* The upcoming app: [@CountessApp](https://twitter.com/CountessApp)
* The author: [@sowenjub](https://twitter.com/sowenjub)
