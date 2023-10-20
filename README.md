# DropDownControl for Swift

DropDownControl is a custom UIControl that facilitates the display of a dropdown list, tailored for IPTV applications. It allows users to select a bouquet from a predefined list.

<p align="center">
  <img src="https://github.com/paoloandrea/DropDownControl/blob/main/Assets/dropdowncontrol_v1.gif.gif?raw=true" alt="Screenshot of DropDownControl" width="250px" />
</p>

## Features:
**Customizable UI:** You can change the label and the appearance of the dropdown list.
**Gesture Recognition:** Tapping on the label or the button triggers the dropdown list.
**Dynamic Data:** Supports dynamic data feeding for the dropdown items.
## Installation Swift Package Manager
Once you have your Swift package set up, adding Floaty as a dependency is as easy as adding it to the dependencies value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/paoloandrea/DropDownControl.git")
]
```

### Initialization:

let dropdownControl = DropDownControl.init()

1. **Configuration:**\
You can configure the **DropDownControl** by using the **withConfig(controllerName:items:)** method.

```swift
let items = [DropDownItems.init(name: "Curabitur pretium orci", totaleChannels: 2),
             DropDownItems.init(name: "Proin sollicitudin", totaleChannels: 523),
             DropDownItems.init(name: "Lorem ipsum", totaleChannels: 70)]
dropdownControl.withConfig(controllerName: "Bouquet", items: items)
```
2. **Item Selection:**\
To handle the event when an item is selected from the dropdown, you can set the didSelectItem closure.

```swift
dropdownControl.didSelectItem = { selectedItem in
    print("Selected Item: \(selectedItem)")
}
```
3. **UI Appearance:**\
You can customize the appearance by modifying properties such as backgroundColor, font, and textColor.

## Preview
If you're using Swift 5.9 or later, you can get a live preview of the DropDownControl in your Xcode canvas.

## Credits
DropDownControl was created by Paolo Rossignoli for IP Television in 2023.

## License
This software is copyrighted by IP Television, 2023. Before using this software in your projects, make sure to check with the legal team about the appropriate licensing terms.