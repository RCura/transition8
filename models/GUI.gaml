/**
 *  T8
 *  Author: Robin
 *  Description: Modelisation de la transition 800-1100, première version
 */

model t8

// L'ordre compte...
import "run.gaml"
	
experiment Exp_Graphique type: gui multicore: true {
	float seed <-  1000.0;
	parameter "Enregistrer sorties ?" var: save_outputs category: "Simulation";
	
	parameter "Annee debut simulation" var: debut_simulation category: "Simulation";
	parameter "Annee fin simulation" var: fin_simulation category: "Simulation";
	
	parameter "Nombre de Foyers Paysans:" var: nombre_foyers_paysans category: "Foyers Paysans";
	parameter "Taux renouvellement" var: taux_renouvellement category: "Foyers Paysans";
	parameter "Taux mobilite des FP" var: taux_mobilite category: "Foyers Paysans";
	parameter "Annee debut besoin protection" var: debut_besoin_protection category: "Foyers Paysans";
	
	parameter "Nombre d'agglomerations secondaires antiques:" var: nombre_agglos_antiques category: "Agregats";
	parameter "Nombre de villages:" var: nombre_villages category: "Agregats";
	parameter "Nombre de Foyers Paysans par village:" var: nombre_foyers_villages category: "Agregats";
	parameter "Puissance Communautes Agraires" var: puissance_comm_agraire min: 0.0 max: 0.75 category: "Agregats";
	
	parameter "Nombre grands seigneurs" var: nombre_grands_seigneurs category: "Seigneurs - Init" min: 1 max: 2;
	parameter "Nombre petits seigneurs" var: nombre_petits_seigneurs category: "Seigneurs - Init";
	
	parameter "Puissance Grand Seigneur 1" var: puissance_grand_seigneur1 category: "Grands Seigneurs";
	parameter "Puissance Grand Seigneur 2" var: puissance_grand_seigneur2 category: "Grands Seigneurs";
	parameter "Probabilite creer chateau GS" var: proba_creer_chateau_GS category: "Grands Seigneurs";
	parameter "Probabilite don chateau GS" var: proba_don_chateau_GS category: "Grands Seigneurs";
	
	//parameter "Probabilite (FP) de devenir seigneur" var: proba_devenir_seigneur category: "Seigneurs";
	parameter "Chatelain peut creer chateau" var: chatelain_cree_chateau category: "Seigneurs";

	parameter "Proba. gain droits haute justice sur chateau" var: proba_gain_droits_hauteJustice_chateau category: "Chatelains";
	parameter "Proba. gain droits banaux sur chateau" var: proba_gain_droits_banaux_chateau category: "Chatelains";
	parameter "Proba. gain droits BM Justice sur chateau" var: proba_gain_droits_basseMoyenneJustice_chateau category: "Chatelains";
	parameter "Probabilite creer chateau PS" var: proba_creer_chateau_PS category: "Chatelains";
	parameter "Probabilite don chateau PS" var: proba_don_chateau_PS category: "Chatelains";
	
	//parameter "Nombre vise de petits seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Petits Seigneurs";
	parameter "Proba. don droits sur ZP" var: proba_don_partie_ZP category: "Petits Seigneurs";	

	parameter "%FP payant un loyer (Petit Seigneur initial) - Borne Min" var: min_fourchette_loyers_PS_init category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "%FP payant un loyer (Petit Seigneur initial) - Borne Max" var: max_fourchette_loyers_PS_init category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "Rayon min Zone Prelevement - Petits Seigneurs Init" var: rayon_min_PS_init category: "Petits Seigneurs" min: 100 max: 20000;
	parameter "Rayon max Zone Prelevement - Petits Seigneurs Init" var: rayon_max_PS_init category: "Petits Seigneurs" min: 100 max: 25000;
	
	parameter "Proba gain nouveaux droits banaux"	var: proba_creation_ZP_banaux category: "Petis Seigneurs";
	parameter "Proba gain nouveaux droits BM justice"	var: proba_creation_ZP_basseMoyenneJustice category: "Petis Seigneurs";

	
	
	parameter "Nombre vise de seigneurs en fin de simulation" var: nombre_seigneurs_objectif category: "Petits Seigneurs";
	parameter "Proba d'obtenir un loyer pour la terre (Petit Seigneur nouveau)" var: proba_collecter_loyer category: "Petits Seigneurs";
	parameter "%FP payant un loyer (Petit Seigneur nouveau) - Borne Min" var: min_fourchette_loyers_PS_nouveau category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "%FP payant un loyer (Petit Seigneur nouveau) - Borne Max" var: max_fourchette_loyers_PS_nouveau category: "Petits Seigneurs" min: 0.0 max: 1.0;
	parameter "Rayon min Zone Prelevement - Petits Seigneurs nouveau" var: rayon_min_PS_nouveau category: "Petits Seigneurs" min: 100 max: 2000;
	parameter "Rayon max Zone Prelevement - Petits Seigneurs nouveau" var: rayon_max_PS_nouveau category: "Petits Seigneurs" min: 100 max: 10000;
	
	parameter "Nombre d'eglises:" var: nombre_eglises category: "Eglises";
	parameter "Dont eglises paroissiales:" var: nb_eglises_paroissiales category: "Eglises" ;
	parameter "Probabilite gain des droits paroissiaux" var: proba_gain_droits_paroissiaux category: "Eglises";
	parameter "Nombre max de paroissiens" var: nb_max_paroissiens category: "Eglises";
	parameter "Nombre min de paroissiens" var: nb_min_paroissiens category: "Eglises";	

	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP CP" value: Foyers_Paysans count (each.comm_agraire);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.type = "Chatelain");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor "Nombre Chateaux" value: length(Chateaux);
		monitor "Attractivite globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivite agregats" value: sum(Agregats where (!each.fake_agregat) collect each.attractivite);
		
		
		display "Carte" {
			species Paroisses transparency: 0.9 ;
			species Zones_Prelevement transparency: 0.9;
			agents "Eglises Paroissiales" value: Eglises where (each.eglise_paroissiale) aspect: base;
			species Chateaux aspect: base ;
			species Agregats transparency: 0.3;
			//species Foyers_Paysans aspect: base ;	
		 	text string(Annee) size: 10000 position: {0, 1} color: rgb("black");
		}
		
	    display "Foyers Paysans" {
	        chart "Demenagements" type: series position: {0,0} size: {0.5,0.5}{
	            data "Local" value: nb_demenagement_local color: #blue; 
	            data "Lointain" value: nb_demenagement_lointain color: #red;
	            data "Non" value: nb_non_demenagement color: #black;
	        }
			chart "FP" type: series position: {0.0,0.5} size: {0.5,0.5}{
	            data "Hors CA" value: Foyers_Paysans count (!each.comm_agraire) color: #blue; 
	            data "Dans CA" value: Foyers_Paysans count (each.comm_agraire)  color: #red;
	        }
    		chart "Satisfaction_FP" type:series position: {0.5,0} size: {0.5,1}{
    			data "Satisfaction Materielle" value: mean(Foyers_Paysans collect each.satisfaction_materielle) color: #blue;
    			data "Satisfaction Religieuse" value: mean(Foyers_Paysans collect each.satisfaction_religieuse) color: #green;
    			data "Satisfaction Protection" value: mean(Foyers_Paysans collect each.satisfaction_protection) color: #red;
    			data "Satisfaction" value: mean(Foyers_Paysans collect each.Satisfaction) color: #black;
    		}
    	}
    	
	    display "FP et preleveurs" {
    		chart "Nombre de Droits acquittes" type:series position: {0,0} size: {1,1}{
    			data "Nb Droits Max" value: max(Foyers_Paysans collect each.nb_preleveurs) color: #blue;
    			data "Nb Droits Mean" value: mean(Foyers_Paysans collect each.nb_preleveurs) color: #green;
    			data "Nb Droits Median" value: median(Foyers_Paysans collect each.nb_preleveurs) color: #orange;
    			data "Nb Droits Min" value: min(Foyers_Paysans collect each.nb_preleveurs) color: #red;
    		}
    	}
    	
    	
    	display "Seigneurs" {
    		chart "Puissance des seigneurs" type:series position: {0,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance) color: #blue;
    			data "Median" value: median(Seigneurs collect each.puissance) color: #orange;
    			data "Max" value: max(Seigneurs collect each.puissance) color: #red;
    		}
    		
    		chart "Puissance armee des seigneurs" type:series position: {0.33,0} size: {0.33,1}{
    			data "Min" value: min(Seigneurs collect each.puissance_armee) color: #green;
    			data "Mean" value: mean(Seigneurs collect each.puissance_armee) color: #blue;
    			data "Med" value:  median(Seigneurs collect each.puissance_armee) color: #orange;
    			data "Max" value: max(Seigneurs collect each.puissance_armee) color: #red;
    		}
    		chart "Dependance (loyer) des FP" type:series position: {0.66,0} size: {0.33,1}{
    			data "FP payant un loyer à un GS" value: Foyers_Paysans count (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Grand Seigneur") color: #green;
    			data "FP payant un loyer à un PS initial" value: Foyers_Paysans count (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and each.seigneur_loyer.initialement_present) color: #blue;
    			data "FP payant un loyer à un PS nouveau" value: Foyers_Paysans count (each.seigneur_loyer != nil and each.seigneur_loyer.type = "Petit Seigneur" and !each.seigneur_loyer.initialement_present) color: #red;
    		}
    	}
    	    	
    	display "Zones Prelevement"{
    		chart "Nombre de ZP" type:series position: {0.0, 0.0} size: {1.0, 0.33}{
    			data "Loyers" value: Zones_Prelevement count (each.type_droit = "Loyer") color: #blue;
    			data "Haute Justice" value: Zones_Prelevement count (each.type_droit = "Haute_Justice") color: #red;
    			data "Banaux" value: Zones_Prelevement count (each.type_droit = "Banaux") color: #green;
    			data "Basse et Moyenne Justice" value: Zones_Prelevement count (each.type_droit = "basseMoyenne_Justice") color: #yellow;
    		}
    		chart "Nb de preleveurs" type: series position: {0, 0.33} size: {1.0, 0.33}{
    			data "Max" value: max ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #red;
    			data "Mean" value: mean ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #green;
    			data "Min" value: min ( Zones_Prelevement collect (length(each.preleveurs.keys))) color: #blue;
    			data "Med" value: median(Zones_Prelevement collect (length(each.preleveurs.keys))) color: #orange;
    		}
    		chart "Nb ZP / Seigneur" type: series position: {0.0, 0.66} size: {1.0, 0.33}{
    			data "Max" value: max(Seigneurs collect each.monNbZP) color: #red;
    			data "Mean" value: mean(Seigneurs collect each.monNbZP) color: #green;
    			data "Median" value: median(Seigneurs collect each.monNbZP) color: #orange;
    			data "Min" value: min(Seigneurs collect each.monNbZP) color: #blue;	
    		}
    	}
    	
    	display "Agregats"{
    		chart "Nombre d'agregats" type: series position: {0.0,0.0} size: {1.0, 0.5}{
    			data "Nombre d'agregats" value: length(Agregats) color: #red;
    			data "Nombre d'agregats avec CA" value: Agregats count (each.communaute_agraire) color: #blue;
    		}
    		chart "Composition des agregats" type: series position: {0.0, 0.5} size: {1.0, 0.5}{
    			data "Max" value: max(Agregats collect length(each.fp_agregat)) color: #red;
    			data "Mean" value: mean(Agregats collect length(each.fp_agregat)) color: #green;
    			data "Median" value: median(Agregats collect length(each.fp_agregat)) color: #orange;
    			data "Min" value: min(Agregats collect length(each.fp_agregat)) color: #blue;
    			
    		}
    	}
    	
    	display "Chateaux/Eglises"{
    		chart "Nombre de chateaux" type: series position: {0.0,0.0} size: {1.0, 0.5}{
    			data "Importants (>=5km)" value: Chateaux count (each.monRayon >= 5000) color: #red;
    			data "Mineurs (<5km)" value: Chateaux count (each.monRayon < 5000) color: #blue;
    		}
    		chart "Eglises" type: series position: {0.0, 0.5} size: {1.0, 0.5}{
    			data "Batiments" value: length(Eglises) color: #red;
    			data "Paroisses" value: Eglises count (each.eglise_paroissiale) color: #blue;
    			
    		}
    	}	
	}
}



experiment Exp_Vide type: gui multicore: true {
	user_command blob {
		geometry test_poly <- polygon([{3,5}, {5,6},{1,4}]);
		write test_poly;
		write test_poly.points;
		write (machine_time as_date "%h%m%s");
		write (as_time(machine_time));
		
	}
	
}


experiment Exp_noInput type: gui {
	parameter "Nombre seigneurs fin" var: nombre_seigneurs_objectif category: "Seigneurs";
	output {
		monitor "Annee" value: Annee;
		monitor "Nombre de Foyers paysans" value: length(Foyers_Paysans);
		monitor "Nombre FP dans agregat" value: Foyers_Paysans count (each.monAgregat != nil);
		monitor "Nombre d'agregats" value: length(Agregats);

		monitor "Nombre FP CP" value: Foyers_Paysans count (each.comm_agraire);
		monitor "Nombre Seigneurs" value: length(Seigneurs);
		monitor "Nombre Grands Seigneurs" value: Seigneurs count (each.type = "Grand Seigneur");
		monitor "Nombre Chatelains" value: Seigneurs count (each.type = "Chatelain");
		monitor "Nombre Petits Seigneurs" value: Seigneurs count (each.type = "Petit Seigneur");
		monitor "Nombre Eglises" value: length(Eglises);
		monitor "Nombre Eglises Paroissiales" value: Eglises count (each.eglise_paroissiale);
		monitor nombre_chateaux value: length(Chateaux);
		monitor "Attractivite globale" value: length(Foyers_Paysans) + sum(Chateaux collect each.attractivite);
		monitor "Attractivite agregats" value: sum(Agregats where (!each.fake_agregat) collect each.attractivite);
			
	}
}

experiment Batch type: batch repeat: 2 keep_seed: true{
   parameter "Nombre seigneurs fin" var: nombre_seigneurs_objectif min: 50 max: 300 step: 25;

   method exhaustive maximize: nb_chateaux;
   permanent {
            	display "Chateaux/Eglises"{
    		chart "Nombre de chateaux" type: series position: {0.0,0.0} size: {1.0, 0.5}{
    			data "Tous" value: length(Chateaux) color: #red;
    		}
    	}	
	}	
 
}