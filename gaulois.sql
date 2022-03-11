-- 1.

SELECT nom_lieu FROM lieu
WHERE nom_lieu LIKE '%um'

-- 2.

SELECT nom_lieu, COUNT(id_personnage) AS nb_Gaulois
FROM personnage p, lieu l
WHERE p.id_lieu = l.id_lieu
GROUP BY p.id_lieu
ORDER BY nb_Gaulois DESC

-- 3.

SELECT nom_personnage, adresse_personnage, nom_specialite, nom_lieu
FROM personnage p, specialite s, lieu l
WHERE p.id_lieu = l.id_lieu 
AND p.id_specialite = s.id_specialite
ORDER BY nom_lieu ASC, nom_personnage

-- 4.

SELECT nom_specialite, COUNT(id_personnage) AS nbGaulois
FROM personnage p, specialite s
WHERE p.id_specialite = s.id_specialite
GROUP BY nom_specialite
ORDER BY nbGaulois DESC

-- 5.

SELECT nom_bataille, DATE_FORMAT(date_bataille, "%d/%m/%Y"), nom_lieu
FROM bataille b, lieu l
WHERE b.id_lieu = l.id_lieu
ORDER BY date_bataille

-- 6.

SELECT nom_potion, SUM(cout_ingredient*qte) AS coutPotion
FROM potion p, ingredient i, composer c
WHERE p.id_potion = c.id_potion
AND c.id_ingredient = i.id_ingredient
GROUP BY nom_potion
ORDER BY coutPotion DESC

-- 7.

SELECT nom_ingredient, cout_ingredient, qte
FROM potion p, ingredient i, composer c
WHERE p.nom_potion = 'Santé'
AND p.id_potion = c.id_potion
AND c.id_ingredient = i.id_ingredient

-- 8.

-- dans un premier temps je construis une "vue" où j'affiche les noms des personnages ayant participé à la bataille "Bataille du village Gaulois" avec les quantités de casques apportés par lesdits personnages

CREATE VIEW competition_casques AS 
    SELECT nom_personnage, nom_bataille, SUM(qte) as total_casques
    FROM bataille b, prendre_casque pC, personnage p
    WHERE b.nom_bataille = 'Bataille du village gaulois'
    AND b.id_bataille = pC.id_bataille
    AND p.id_personnage = pC.id_personnage
    GROUP BY nom_personnage

-- je fais ensuite un select classique en utilisant une sous-requête dans ma condition

SELECT nom_personnage, total_casques
FROM competition_casques
WHERE total_casques = (SELECT MAX(total_casques) FROM competition_casques)

-- 9.

SELECT nom_personnage, SUM(dose_boire) AS total_doses_potions
FROM personnage p, boire b
WHERE p.id_personnage = b.id_personnage
GROUP BY nom_personnage
ORDER BY total_doses_potions DESC

-- 10.

-- même procédé qu'en 8

CREATE VIEW batailles_casques AS 
	SELECT nom_bataille, SUM(qte) AS total_casques
	FROM bataille b, prendre_casque pc
	WHERE b.id_bataille = pc.id_bataille
	GROUP BY nom_bataille
	ORDER BY total_casques DESC

SELECT nom_bataille, total_casques
FROM batailles_casques
WHERE total_casques = (SELECT MAX(total_casques) FROM batailles_casques)

-- 11.

SELECT nom_type_casque, SUM(cout_casque) AS cout_total
FROM type_casque tc, casque c
WHERE tc.id_type_casque = c.id_type_casque
GROUP BY nom_type_casque
ORDER BY cout_total DESC

-- 12.

SELECT nom_potion
FROM potion p, composer c, ingredient i
WHERE i.nom_ingredient = 'Poisson frais'
AND i.id_ingredient = c.id_ingredient 
AND c.id_potion = p.id_potion
GROUP BY nom_potion

-- 13.

CREATE VIEW lieu_habitants AS
	SELECT nom_lieu, COUNT(id_personnage) AS nb_habitants
	FROM lieu l, personnage p
	WHERE l.id_lieu = p.id_lieu
	GROUP BY nom_lieu
	ORDER BY nb_habitants DESC

SELECT nom_lieu, nb_habitants
FROM lieu_habitants
WHERE nb_habitants =    (SELECT MAX(lieu_habitants_sans_village_gaulois.nb_habitants) 
                        FROM (SELECT nom_lieu, nb_habitants
                                FROM lieu_habitants
                                WHERE nom_lieu <> 'Village gaulois') lieu_habitants_sans_village_gaulois
					    )

-- seconde méthode

SELECT lieu_hab.nom_lieu, lieu_hab.nb_habitants
FROM    (   SELECT nom_lieu, COUNT(id_personnage) AS nb_habitants
            FROM lieu l, personnage p
            WHERE l.id_lieu = p.id_lieu
            GROUP BY nom_lieu
        )  lieu_hab
WHERE lieu_hab.nb_habitants =    (    
	SELECT MAX(lieu_hab_sans_village_gaulois.nb_habitants) 
   FROM    (   SELECT lieu_hab.nom_lieu, lieu_hab.nb_habitants
               FROM (SELECT nom_lieu, COUNT(id_personnage) AS nb_habitants
            				FROM lieu l, personnage p
            				WHERE l.id_lieu = p.id_lieu
            				GROUP BY nom_lieu) lieu_hab
               WHERE lieu_hab.nom_lieu <> 'Village gaulois'
            ) lieu_hab_sans_village_gaulois
)

-- 14.

SELECT nom_personnage
FROM personnage p
LEFT JOIN boire b
ON p.id_personnage = b.id_personnage
WHERE b.id_personnage IS NULL