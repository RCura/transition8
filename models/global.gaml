/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */
model t8

import "init.gaml"
import "Agents/Agregats.gaml"
import "Agents/Foyers_Paysans.gaml"
import "Agents/Chateaux.gaml"
import "Agents/Eglises.gaml"
import "Agents/Seigneurs.gaml"
import "Agents/Attracteurs.gaml"
import "Agents/Zones_Prelevement.gaml"


global torus: false{
	
	
	///////////////
	// TECHNIQUE //
	///////////////
	
	bool benchmark <- false;
	bool save_outputs <- false;
	string prefix_output <- "5_1";
	string output_folder_path <- "/home/robin/SimFeodal/outputs/";
	int debut_simulation <- 800;
	int fin_simulation <- 1160;
	int duree_step <- 20;
	string experimentType <- "batch";
	bool summarised_outputs <- false;
	string sensibility_parameter <- "";
	string sensibility_value <- "" ;
	
	////////////
	// INPUTS //
	////////////
	
	// ESPACE DU MODELE //
	int taille_cote_monde <- 80 ; // km
	// FOYERS PAYSANS //
	int init_nb_total_fp <- 4000 ; // XXX : anciennement : nombre_foyers_paysans : Renommé dans BDD
	// AGREGATS //
	int init_nb_agglos <- 4 ; // XXX : anciennement : nombre_agglos_antiques : Renommé dans BDD
	int init_nb_fp_agglo <- 30; // XXX : anciennement en dur : Ajouté dans BDD
	int init_nb_villages <- 20 ; // XXX : anciennement : nombre_villages : Renommé dans BDD
	int init_nb_fp_village <- 10; // XXX : anciennement : nombre_FP_village : Renommé dans BDD
	// SEIGNEURS //
	int init_nb_gs <- 2; // XXX : anciennement : nombre_grands_seigneurs : Renommé dans BDD
	float puissance_grand_seigneur1 <- 0.5; // Anciennement 5 : FIXME : A transformer dans BDD
	float puissance_grand_seigneur2 <- 0.5; // Anciennement 5 : FIXME : A transformer dans BDD
	int init_nb_ps <- 18; // XXX : anciennement : nombre_petits_seigneurs : Renommé dans BDD
	// EGLISES //
	int init_nb_eglises <- 150 ; // XXX : anciennement : nombre_eglises : Renommé dans BDD
	int init_nb_eglises_paroissiales <- 50 ; // XXX : anciennement : nb_eglises_paroissiales : Renommé dans BDD
		
	//////////////
	// CONTEXTE //
	//////////////
	
	// FOYERS PAYSANS //
	float taux_augmentation_FP <- 0.0; // FIXME : renommer en croissance_demo + BDD : avant v6 : taux_augmentation_FP
	float taux_renouvellement <- 0.05 ; // FIXME : renommer en taux_renouvellement_fp + BDD : avant v6 : taux_renouvellement
	float proba_FP_dependants <- 0.2; // FIXME : renommer en proba_fp_dependant : avant v6 : proba_FP_dependants
	map<int,float> besoin_protection_fp <- [800::0,960::0.2,980::0.4,1000::0.6,1020::0.8,1040::1.0]; // FIXME: Ajout d'un paramètre qui modifie la valeur de la variable besoin_protection
	// FIXME : Ajouter dans BDD : nouveau param en v6
	// AGREGATS //
	float puissance_communautes <- 0.25;
	int coef_redevances <- 15;
	// SEIGNEURS //
	int nombre_seigneurs_objectif <- 200;
	map<int,float> proba_gs_droits_haute_justice <- [800::0,900::0.1,1000::1.0]; // TODO : Inactif : ajouter dans modèle + Ajouter aux outputs + SimEDB
	int debut_cession_droits_seigneurs <- 900 ; // TODO: Inactif : intégrer + outputs + SimEDB
	int debut_garde_chateaux_seigneurs <- 960 ; // TODO : Inactif : intégrer + outputs + SimEDB
	// CHATEAUX //
	int apparition_chateaux <- 960;
	map<int,bool> periode_promotion_chateaux <- [800::false,940::true,1040::true,1060::false]; // // TODO : Inactif : intégrer + outputs + SimEDB
	
	///////////////
	// MECANISME //
	///////////////
	
	// FOYERS PAYSANS //
	map<int,int> dist_min_eglise <- [800::5000,960::3000,1060::1500]; // TODO : Inactif : intégrer + outputs + SimEDB
	map<int,int> dist_max_eglise <- [800::25000,960::10000,1060::5000]; // TODO : Inactif : intégrer + outputs + SimEDB
	int dist_min_chateau <- 1500; // TODO : Inactif : intégrer + outputs + SimEDB
	int dist_max_chateau <- 5000; // TODO : Inactif : intégrer + outputs + SimEDB
	map<int,int> seuils_distance_max_dem_local <- [800::2500]; // TODO : Inactif : intégrer + outputs + SimEDB
	float proba_ponderee_deplacement_lointain <- 0.2; // TODO : Vérifier
	// AGREGATS //
	int nombre_FP_agregat <- 5;
	float proba_apparition_communaute <- 0.2;
	int distance_detection_agregats <- 100;
	int distance_fusion_agregat <- 100; // TODO : Inactif : intégrer + outputs + SimEDB
	int apparition_communautes <- 800; // FIXME : Ne sert plus à rien ?
	// SEIGNEURS //
	float proba_collecter_loyer <- 0.1;
	float proba_creation_ZP_banaux <- 0.05;
	float proba_creation_ZP_basseMoyenneJustice <- 0.05;
	int rayon_min_PS <- 1000;
	int rayon_max_PS <- 5000;
	float min_fourchette_loyers_PS <- 0.05;
	float max_fourchette_loyers_PS <- 0.25;
	float proba_don_partie_ZP <- 0.33;
	int rayon_cession_droits_ps <- 3000; // TODO : Inactif : intégrer + outputs + SimEDB
	float proba_don_chateau_GS <- 0.50;
	float proba_gain_droits_hauteJustice_chateau <- 0.1;
	
	
	int nb_chateaux_potentiels_GS <- 2;
	int seuil_attractivite_chateau <- 3000;
	float proba_chateau_agregat <- 0.5; // FIXME : A appliquer aussi aux PS
	
	
	float proba_gain_droits_banaux_chateau <- 0.1;
	float proba_gain_droits_basseMoyenneJustice_chateau <- 0.1;
	float proba_promotion_groschateau_multipole <- 0.8;
	float proba_promotion_groschateau_autre <- 0.3;
	
	
	
	
	
	
	////////////////////////
	// VARIABLE GLOBABLES //
	////////////////////////
	
	int Annee <- debut_simulation update: Annee + duree_step;
	geometry world_bounds <- square(taille_cote_monde #km) translated_by {taille_cote_monde #km/2 , taille_cote_monde #km/2 };
	
	geometry shape <- envelope(world_bounds) ;
	geometry worldextent <- envelope(world_bounds) ;
	geometry reduced_worldextent <- worldextent - 1 #km; // On retranche 1km de chaque coté du monde
	
	int nb_seigneurs_a_creer_total <- nombre_seigneurs_objectif - (init_nb_gs + init_nb_ps);
	int nb_moyen_petits_seigneurs_par_tour <- round(nb_seigneurs_a_creer_total / ((fin_simulation - debut_simulation) / duree_step));
	
	int distance_max_dem_local <- 4000;
	float besoin_protection <- 0.0; // FIXME : Corriger nom param dans outputs et SimEDB

	/////////////
	// OUTPUTS //
	/////////////
	float distance_eglises_paroissiales <- 0.0;
	float distance_eglises <- 0.0;
	float prop_FP_isoles <- 0.0;
	float ratio_charge_fiscale <- 0.0;
	float charge_fiscale_debut <- 0.0;
	float charge_fiscale <- 0.0;
	float dist_ppv_agregat <- 0.0;
	list<int> Chateaux_chatelains <- [];
	list<int> reseaux_chateaux <- [];
	// FP //
	int nb_demenagement_local update: 0; // le update remet à 0 au début de chaque nouveau step
	int nb_demenagement_lointain update: 0;
	// CHATEAUX //
	int nb_chateaux ;
	// OpenMole outputs //
	int nb_agregats_om <- 0 ;
	int nb_chateaux_om <- 0 ;
	int nb_gros_chateaux_om <- 0 ;
	int nb_seigneurs_om <- 0 ;
	int nb_eglises_om <- 0 ;
	int nb_eglises_paroissiales_om <- 0 ;
	int distance_eglises_paroissiales_om <- 0 ;
	float proportion_fp_isoles_om <- 0.0 ;
	float augmentation_charge_fiscale_om <- 0.0 ;


	
	// FOYERS_PAYSANS //
	
	


	int seuil_puissance_armee <- 400; // P.A. d'un proprio de chateau pour que le FP soit satisfait.

	

	bool serfs_mobiles <- true;
	float min_S_distance_chateau <- 0.0; // Nouveau paramètre pour le calcul de s_protection
	
	 
	// SEIGNEURS //
	
	



	// ZONES_PRELEVEMENT //


	// EGLISES //
	
	
	int nb_max_paroissiens <- 40;
	int nb_min_paroissiens <- 10;
	int seuil_creation_paroisse <- 600;
	int nb_paroissiens_mecontents_necessaires <- 20;
	
	// POLES //
	float attrac_0_eglises <- 0.0;
	float attrac_1_eglises <- 0.15;
	float attrac_2_eglises <- 0.25;
	float attrac_3_eglises <- 0.5;
	float attrac_4_eglises <- 0.6;
	float attrac_GC <- 0.25;
	float attrac_PC <- 0.15;
	float attrac_communautes <- 0.15;
	
	
	////////////
	/// TEMP ///
	////////////
	

	
	
	action update_variables_temporelles {
		if ((besoin_protection_fp at Annee) is float){
			set besoin_protection <- besoin_protection_fp at Annee;
		}
		
		if Annee < 900 {
			set distance_max_dem_local <- seuils_distance_max_dem_local[0];
		} else if (Annee >= 900 and Annee < 1000) {
			 set distance_max_dem_local <- seuils_distance_max_dem_local[1];
		} else  if (Annee >= 1000) {
			set distance_max_dem_local <- seuils_distance_max_dem_local[2];
		}
		
		
		
//	map<int,float> proba_gs_droits_haute_justice <- [800::0,900::0.1,1000::1.0]; // TODO : Inactif : ajouter dans modèle + Ajouter aux outputs + SimEDB
//	map<int,bool> periode_promotion_chateaux <- [800::false,940::true,1040::true,1060::false]; // // TODO : Inactif : intégrer + outputs + SimEDB
//	map<int,int> dist_min_eglise <- [800::5000,960::3000,1060::1500]; // TODO : Inactif : intégrer + outputs + SimEDB
//	map<int,int> dist_max_eglise <- [800::25000,960::10000,1060::5000]; // TODO : Inactif : intégrer + outputs + SimEDB
//	map<int,int> seuils_distance_max_dem_local <- [800::2500]; // TODO : Inactif : intégrer + outputs + SimEDB
	}
	

	action update_output_indexes {
		float t <- machine_time;
		list<float> distances_pp_eglise <- [];
		ask Eglises {
			Eglises pp_eglise <- Eglises closest_to self;
			if (pp_eglise != nil){
			float distEglise <- self distance_to pp_eglise;
			distances_pp_eglise <+ distEglise;
			}
		}
		set distance_eglises <- mean(distances_pp_eglise);
		if (benchmark){write 'update_output_indexes_1 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<float> distances_pp_paroisses <- [];
		list<Eglises> eglises_paroissiales <- Eglises where (each.eglise_paroissiale);
		ask eglises_paroissiales{
			Eglises pp_eglise <- (eglises_paroissiales - self) closest_to self;
			if (pp_eglise != nil){
			float distEglise <- self distance_to pp_eglise;
			distances_pp_paroisses <+ distEglise;
			}
		}
		
		set distance_eglises_paroissiales <- mean(distances_pp_paroisses);
		if (benchmark){write 'update_output_indexes_2 : ' + string(machine_time - t);}
		set t <- machine_time;
		
		set prop_FP_isoles <- Foyers_Paysans count (each.monAgregat = nil) / length(Foyers_Paysans);
		set charge_fiscale <- mean(Foyers_Paysans collect float(each.nb_preleveurs));
		
		list<Foyers_Paysans> FP_Agregat <- Foyers_Paysans where (each.monAgregat != nil);
		if (benchmark){write 'update_output_indexes_3 : ' + string(machine_time - t);}
//		float t <- machine_time;
//		list<float> liste_ppv_agregats <- [];
//		ask FP_Agregat {
//			list<Foyers_Paysans> mesFP <- (Foyers_Paysans where (each.monAgregat = self.monAgregat)) - self;
//			if (!empty(mesFP)){
//				float myDist <- self distance_to (mesFP with_min_of (each distance_to self));
//				liste_ppv_agregats <+ myDist;
//			}
//		}
//		set dist_ppv_agregat <- mean(liste_ppv_agregats);
//		if (benchmark){write 'update_output_indexes_4 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<int> nbChateaux_chatelains <- []; 
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where ( (each.proprietaire = self) or (each.gardien = self) );
			set nbChateaux_chatelains <- nbChateaux_chatelains +  length(mesChateaux);	
		}
		set Chateaux_chatelains <- nbChateaux_chatelains;
		if (benchmark){write 'update_output_indexes_5 : ' + string(machine_time - t);}
		set t <- machine_time;
		list<int> nbChateaux_reseau <- [];
		ask Seigneurs where (each.type != "Petit Seigneur"){
			list<Chateaux> mesChateaux <- Chateaux where (each.proprietaire = self);
			set nbChateaux_reseau <- nbChateaux_reseau +  length(mesChateaux);	
		}
		set reseaux_chateaux <- nbChateaux_reseau;
		if (benchmark){write 'update_output_indexes_6 : ' + string(machine_time - t);}
	}
}
