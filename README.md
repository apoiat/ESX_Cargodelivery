# esx_cargodelivery

### Requirements
* ESX Police job
  * [esx_policejob](https://github.com/ESX-Org/esx_policejob)
* GCPhone
  * [GCPhone](https://github.com/N3MTV/gcphone) (for the text messages to work)

## Download & Installation

### Using Git
```
cd resources
git clone https://github.com/apoiat/esx_cargodelivery [esx]/esx_cargodelivery
```

### Manually
- Download https://github.com/apoiat/esx_cargodelivery/archive/master.zip
- Put it in the `[esx]` directory


## Installation
- Add this in your server.cfg :

```
start esx_cargodelivery
```
-  * If you want to notify more societies add them at Config.AlertExtraSocieties.
	 example: Config.AlertExtraSocieties = { "mafia", "bikers" }
