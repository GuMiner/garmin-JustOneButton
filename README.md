# JustOneButton
A Garmin Watchface with one button to interact with a https://www.home-assistant.io/ switch

# About
**JustOneButton** is when you just want one button.

![image of app](./Demo.jpg)

This button connects to a [HomeAssistant](https://www.home-assistant.io/) server to
perform an IoT home automation task, such as turning a switch on and off.

# Setup
1. [Install HomeAssistant](./HomeAssistantSetup.md) 
2. Install **JustOneButton** on the watch
3. Set the following settings
   * **Auth Bearer Token**
     - *Example:* eyJ0....5E
   * **Status URI**
     - *Example:* https://your_server/api/states/switch.my_switch
   * **Turn on URI**
     - *Example:* https://your_server/api/services/switch/turn_on
   * **Turn off URI**
     - *Example:* https://your_server/api/services/switch/turn_off
   * **Entity ID**
     - *Example:* switch.my_switch

# Instructions
Click the center button and the switch will turn on.

Click it again and the switch will turn off.

## Legend
### Inner Ring
* **Light Gray**: Unknown switch status
* **Red**: Switch is on
* **Green**: Switch is off

### Outer Ring
* **Blue**: No action pending
* **Yellow**: Changing switch state, waiting for response.
* **Red**: Network error. 

## Diagnosing Errors
Error diagnosis is a tricky process with embedded devices. Please make sure:
- All URIs are HTTPS and the SSL certificate used is trusted
- The Auth bearer token is correct, has no leading or trailing spaces, and does not include the 'Bearer ' phrase.
- The correct 'switch.my_switch' Home Assistant device exists.

# Advanced Setup
If you don't have or want a Home Assistant server, you can setup your own server.

## Server API
The watchface will call the following APIs on the server using settings provided to the watchface.

### Get Status
**Request**
```
GET STATUS_URI
Authorization Bearer AUTH_BEARER_TOKEN
Content-Type application/json
```
**Expected Response**
```
200 OK
Content-Type application/json
```

If the switch is off, the ```Content``` should be ```{"state": "off"}```. Otherwise, the ```Content``` should be ```{"state": "on"}```.

Additional JSON key-value pairs returned, if any, will be ignored.

### Turn On
**Request**
```
POST TURN_ON_URI
Authorization Bearer AUTH_BEARER_TOKEN
Content-Type application/json
Content {"entity_id": "ENTITY_ID"}
```
**Expected Response**
```
200 OK
Content-Type application/json
```

### Turn Off
The *Turn Off* API is identical to the *Turn On* API, except for the URI.

**Request**
```
POST TURN_OFF_URI
Authorization Bearer AUTH_BEARER_TOKEN
Content-Type application/json
Content {"entity_id": "ENTITY_ID"}
```
**Expected Response**
```
200 OK
Content-Type application/json
```


