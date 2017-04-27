/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8

import "init.gaml"
import "global.gaml"
import "outputs.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"


global schedules: list(world) + list(Attracteurs) + list(Poles)+ list(Agregats) + list(Foyers_Paysans) + list(Chateaux) + list(Eglises) + list(Seigneurs){
    
	init {
		float t <- machine_time;
		do generer_monde;
		if (benchmark){write 'init : ' + string(machine_time - t);}
	}
		
	reflex renouvellement_monde when: (time > 0){
		float t <- machine_time;
		do renouvellement_FP;
		if (benchmark){write 'renouvellement_monde : ' + string(machine_time - t);}
	}
		
	reflex MaJ_globals {
		float t <- machine_time;
		if (augmentation_max_dem_local) {do update_distance_max_dem_local;}
		do update_besoin_protection;
		if (benchmark){write 'MaJ_globals : ' + string(machine_time - t);}
	}	

	reflex MaJ_paroisses {
		float t <- machine_time;
		do compute_paroisses ; // On redécoupe
		do create_paroisses ; // On crée les paroisses des agrégats
		do compute_paroisses ; // On redessine
		do promouvoir_paroisses; // On nomme/crée de  nouvelles paroisses là où la population est mal desservie
		do compute_paroisses ; // On redessine
		if (benchmark){write 'MaJ_paroisses : ' + string(machine_time - t);}
	}

	reflex MaJ_poles {
		float t <- machine_time;
		do update_poles_alternate;
		if (benchmark){write 'MaJ_poles : ' + string(machine_time - t);}
	}
	
	// Changement 4_4 ! TODO
	// On déplace Satisfaction ici alors que c'était juste avant MaJ Agrégats
	reflex MaJ_satisfaction_FP {
		float t0 <- machine_time;
		ask  Foyers_Paysans {	do update_satisfaction_materielle;}
		if (benchmark){write 'update_satisfaction_materielle : ' + string(machine_time - t0);}
		float t <- machine_time;
		ask  Foyers_Paysans {	do update_satisfaction_religieuse;}
		if (benchmark){write 'update_satisfaction_religieuse : ' + string(machine_time - t);}
		set t <- machine_time;
		ask  Foyers_Paysans {	do update_satisfaction_protection;}
		if (benchmark){write 'update_satisfaction_protection : ' + string(machine_time - t);}
		set t <- machine_time;
		ask Foyers_Paysans {
			if (!satisfaction_alternate){
				set Satisfaction <- min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
			} else {
				set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
				if (self.monAgregat != nil) {
					if (self.monAgregat.communaute) {set Satisfaction <- Satisfaction + 0.25;}
					}
				}
			}
		if (benchmark){write 'Maj_Satis_globale : ' + string(machine_time - t);}		
//		ask  Foyers_Paysans {
//			do update_satisfaction_materielle;
//			do update_satisfaction_religieuse;
//			do update_satisfaction_protection;
//			
//			if (!satisfaction_alternate){
//				set Satisfaction <- min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
//			} else {
//				set Satisfaction <- 0.75 * min([satisfaction_religieuse, satisfaction_protection,  satisfaction_materielle]);
//				if (self.monAgregat != nil) {
//					if (self.monAgregat.communaute) {set Satisfaction <- Satisfaction + 0.25;}
//				}
//				
//			}
//			
//			
//		}
	if (benchmark){write 'MaJ_satisfaction_FP : ' + string(machine_time - t0);}
	}
	
	reflex Deplacement_FP {
		float t <- machine_time;
		ask Foyers_Paysans where (each.mobile) {
			do deplacement;
		}
		if (benchmark){write 'Deplacement_FP : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Droits_Seigneurs {
		float t <- machine_time;
		ask Seigneurs where (each.type="Grand Seigneur"){do MaJ_droits_Grands_Seigneurs;}
		ask Seigneurs where (each.type != "Grand Seigneur") {
			do MaJ_droits_Petits_Seigneurs;
			do gains_droits_PS;
		}
		if (benchmark){write 'MaJ_Droits_Seigneurs : ' + string(machine_time - t);}
	}
	
	reflex MaJ_ZP_et_preleveurs {
				float t <- machine_time;
		ask Zones_Prelevement {do update_shape;}
		ask Foyers_Paysans {do reset_preleveurs;}
		ask Seigneurs {do reset_variables;}
		do attribution_loyers_FP;

		ask Zones_Prelevement where (each.type_droit = "Haute_Justice"){do update_taxes_FP_HteJustice;}
		ask Zones_Prelevement where (each.type_droit = "Banaux"){do update_taxes_FP_Banaux;}
		ask Zones_Prelevement where (each.type_droit = "basseMoyenne_Justice"){do update_taxes_FP_BM_Justice;}
				if (benchmark){write 'MaJ_ZP_et_preleveurs : ' + string(machine_time - t);}
	}
	
	reflex Dons_des_Seigneurs {
float t <- machine_time;
		// Don droits
		if (Annee >= 900) {
			ask Seigneurs where (each.type = "Grand Seigneur"){ do don_droits_GS; }
			ask Seigneurs where (each.type != "Grand Seigneur"){ do don_droits_PS; }
		}
		// Don châteaux
		if (Annee >= 950) {
			ask Seigneurs where (each.type = "Grand Seigneur"){
				do update_droits_chateaux_GS;
				do don_chateaux_GS;
			}
		}
		ask Seigneurs {
			do MaJ_puissance; 
			do MaJ_puissance_armee;
		}
	if (benchmark){write 'Dons_des_Seigneurs : ' + string(machine_time - t);}
	}
	
	// Changement 4_4 ! TODO
	// La promotion était juste après MaJ Poles et arrive encore plus tard 
	reflex Promotion_Chateaux when: (Annee >= 940 and Annee <= 1040){
		float t <- machine_time;
			ask Chateaux where (each.type = "Petit Chateau"){
				do promotion_chateau;
			}	
			if (benchmark){write 'Promotion_Chateaux : ' + string(machine_time - t);}
	}
	
	reflex Constructions_chateaux when: Annee >= apparition_chateaux{
		float t <- machine_time;
		ask Seigneurs where (each.type = "Grand Seigneur" and each.puissance > puissance_necessaire_creation_chateau_GS) {
			do construction_chateau_GS;
		}
		ask Seigneurs where (each.type != "Grand Seigneur" and each.puissance > puissance_necessaire_creation_chateau_PS){
			do construction_chateau_PS;
		}
			if (benchmark){write 'Constructions_chateaux : ' + string(machine_time - t);}
	}
	
	reflex MaJ_Agregats{
				float t <- machine_time;
		if (agregats_simplifie){
			do update_agregats_simplifie;
		} else {
			do update_agregats_alternate;
		}
		
		do creation_nouveaux_seigneurs;
		if (length(Chateaux) > 0){
			ask Agregats {do update_chateau;}
		}
		ask Agregats {do update_attractivite;}
					if (benchmark){write 'MaJ_Agregats : ' + string(machine_time - t);}
	}
	
	reflex update_plot {
						float t <- machine_time;
		ask Seigneurs {
			set monNbZP <- Zones_Prelevement count ((each.preleveurs.keys contains self) or (each.proprietaire = self));
		}
							if (benchmark){write 'update_plot : ' + string(machine_time - t);}
	}
	
	reflex update_outputs when: (Annee > debut_simulation){
								float t <- machine_time;
		if (Annee = (debut_simulation + duree_step)){
			set charge_fiscale_debut <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
		}
		//do update_agregats_fp ;
		do update_output_indexes;
		do update_outputs_fp;
if (benchmark){write 'update_outputs : ' + string(machine_time - t);}
		write "Seed : " + myseed + " / Annee : " + Annee + " / Nb Agregats : " + length(Agregats) + " / TxIsoles : " + prop_FP_isoles;
	}
	
	reflex save_data when: save_outputs {
										float t <- machine_time;
		do save_Parameters;
		do save_FP;
		do save_Agregats;
		do save_ZP;
		do save_Chateaux;
		do save_Seigneurs;
		do save_Eglises;
		do save_Paroisses;
		if (benchmark){write 'update_outputs : ' + string(machine_time - t);}
	}
	
	reflex save_TMD_data when: save_TMD {
										float t <- machine_time;
		do save_TMD;
		if (benchmark){write 'save_TMD_data : ' + string(machine_time - t);}
	}
	
	reflex fin_simulation {
										float t <- machine_time;
		set nb_chateaux <- length(Chateaux);
		if (Annee >= fin_simulation) {
			write 'Durée simulation : ' + total_duration;
			//do halt; // Si version  batch
			do pause; // Si version GUI
		}
		if (benchmark){write 'fin_simulation : ' + string(machine_time - t);}
	}
}