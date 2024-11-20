import csv

# rewrite file by deleting certain columns
with open("donnees/digit_writing.txt", 'r') as csv_file:
    csv_reader = csv.reader(csv_file)

    # Ecriture des données sur un fichier txt
    nom_fichier = "donnees/digit_writing_processed.txt"
    with open(nom_fichier, 'w') as txt_file:
        # ne pas prendre la première ligne qui contient les noms des colonnes:
        for i, row in enumerate(csv_reader):
            # if i == 0:
            #     nb_var = len(row) - 1
            # else:
                # join all columns except the second  (all columns including the first, third and beyond)
            # txt_file.write(",".join(row[1:36] + row[38:]) + '\n')

            #  join all columns except the 37th (all columns including the first, second and beyond)
            txt_file.write(",".join(row[1:38] + row[39:]) + '\n')
                