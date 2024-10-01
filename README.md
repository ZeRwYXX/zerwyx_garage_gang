
# Garage Gangs - Location de Véhicules

Un script de location de véhicules multi-gang conçu pour les serveurs FiveM, permettant aux joueurs d'accéder à un garage spécifique pour chaque gang, avec des véhicules configurables, des stocks, des couleurs personnalisées, et un système de code d'accès sécurisé.

## Fonctionnalités

- **Location de véhicules par gang** : Chaque gang dispose de son propre PNJ permettant la location de véhicules avec un code d'accès personnalisé.
- **Configuration avancée** : Chaque véhicule peut être configuré avec un stock, une couleur, et une image personnalisée.
- **Notifications intégrées** : Notifications en HTML pour informer le joueur de la réussite ou de l'échec des actions.
- **Système de clé de véhicule** : Intégration avec le script `ak47_vehiclekeys` pour la gestion des clés de véhicules loués.
- **Gestion des stocks** : Les véhicules retournent automatiquement au stock lorsqu'ils sont supprimés.

## Installation

1. Clonez ou téléchargez le contenu de ce dépôt.
2. Placez le dossier dans votre répertoire `resources`.
3. Ajoutez `ensure garage_gangs` dans votre fichier `server.cfg`.

## Configuration

La configuration se trouve dans `config.lua`.

### Exemple de configuration

```lua
Config = {}

Config.PedLocations = {
    vagos = {
        coords = vector4(313.3225, -2040.608, 20.93671, 318.1541), 
        spawnVehicle = vector4(316.7622, -2031.936, 20.57616, 311.9013),
        spawnDeleter = vector4(323.7209, -2023.531, 20.92667, 138.7005),
        vehicles = {
            panto = {stock = 3, color = {255, 255, 0}, img = "./img/panto.png"},
            akuma = {stock = 3, color = {0, 0, 255}, img = ""}, -- Laisse le champ 'img' vide si tu veux utiliser l'URL par défaut
            kuruma = {stock = 4, color = {255, 0, 0}, img = ""},
        },
        code = "1234" -- Code d'accès pour le gang des Vagos
    },
    ballas = {
        coords = vector4(116.1953, -1953.752, 20.7513, 45.11762), 
        spawnVehicle = vector4(107.799, -1951.074, 20.63129, 298.7335),
        spawnDeleter = vector4(107.799, -1951.074, 20.63129, 298.7335),
        vehicles = {
            panto = {stock = 3, color = {255, 105, 180}, img = ""},
            kuruma = {stock = 4, color = {0, 255, 0}, img = ""},
        },
        code = "5678" -- Code d'accès pour le gang des Ballas
    }
}
```

- **coords** : Position du PNJ pour chaque gang.
- **spawnVehicle** : Position de spawn des véhicules loués.
- **spawnDeleter** : Position pour supprimer les véhicules.
- **vehicles** : Liste des véhicules disponibles avec leur stock, couleur, et image.
- **code** : Code d'accès pour accéder à la location du gang.

## Utilisation

1. Approchez-vous du PNJ de votre gang et utilisez la touche d'interaction pour ouvrir le menu de location.
2. Entrez le code d'accès fourni par votre gang.
3. Choisissez un véhicule parmi la liste disponible et cliquez sur "Louer".
4. Votre véhicule apparaîtra à la position de spawn définie.

## Intégration des images de véhicules

Les images des véhicules sont chargées à partir de `./img/` ou directement depuis le lien par défaut : `https://fast-rp.fr/cardealer/img/vehicles/NOMDUVEHICULE.png`.

## Remerciements

Merci à tous ceux qui ont contribué à ce projet et à la communauté FiveM pour leur soutien continu.

## Support

Pour toute question ou assistance, veuillez contacter [votre Discord ou site web de support].

## Avertissement

Ce script est fourni tel quel. Veuillez faire un backup avant de l'utiliser sur votre serveur.
