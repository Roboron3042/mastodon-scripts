#!/bin/bash

set -e

DIR=$(pwd)
LIVE=$DIR/../live

cd $LIVE
git checkout .
# Read the options from a file
SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
options=$(git tag -l | tail -n 6)
options=($options) # split the `names` string into an array by the same name
IFS=$SAVEIFS   # Restore original IFS

# Display the menu and get user input
printf "\nElige una versión para obtener. Si hay conflictos, tendrás que resolverlos. "
select opt in "${options[@]}" "Exit"; do
    case $opt in
        *)
            printf "\nObteniendo tag $opt y aplicando parche...\n"
            git checkout $opt
            git apply $DIR/mastoes.diff
            break
            ;;
    esac
done

printf "\nInstalando dependencias (bundle install)..."
bundle install

printf "\nInstalando dependencias (yarn install --immutable)..."
yarn install --immutable

printf "\nAparte de precompilar assets, sigue cualquier instrucción adicional y pulsa enter para continuar: https://github.com/mastodon/mastodon/releases/tag/$opt"

read -s -n 1

printf "\nInstalando temas y precompilando assets...\n"
cd $DIR
echo "$(pwd)"
./actualizar_temas.sh
cd $LIVE

#RAILS_ENV=production bundle exec rails assets:precompile

printf "\nReiniciando servicios..."
sudo systemctl reload-or-restart mastodon-{web,streaming,sidekiq-*}

printf "\n¡Actualización completada! Revisa que todo funciona correctamente.\n"
