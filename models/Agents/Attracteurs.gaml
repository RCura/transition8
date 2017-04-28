/**
 *  T8
 *  Author: Robin
 *  Description: Modélisation de la transition 800-1100, première version
 */

model t8


import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Agregats.gaml"
import "Eglises.gaml"
import "Chateaux.gaml"
import "Seigneurs.gaml"
import "Zones_Prelevement.gaml"

global {
	
	action update_poles {
		
		ask Poles {do die;}
    	// ****************************** //
    	// Detection des poles d'agrégats //
    	// ****************************** //
    	
    	list<Agregats> agregats_dans_poles <- list(Agregats);
    	list<Chateaux> chateaux_dans_poles <- list(Chateaux);
    	list<Eglises> eglises_dans_poles <- Eglises where each.eglise_paroissiale;
    	ask Agregats {
    		if ((length(mesChateaux) + length(mesParoisses)) >= 1){
    			create Poles number: 1 {
					set mesAttracteurs <- myself.mesChateaux + myself.mesParoisses;
					if(myself.communaute){mesAttracteurs <+ myself;}
					set shape <- myself.shape;
					set monAgregat <- myself;
    			}
    			agregats_dans_poles >- self;
    			chateaux_dans_poles >- mesChateaux;
    			eglises_dans_poles >- mesParoisses;
    		}
    	}
		
		list<list> poles_uniques <- simple_clustering_by_distance((eglises_dans_poles + chateaux_dans_poles + (agregats_dans_poles where each.communaute)) of_generic_species Attracteurs, 200);

		loop currentPole over: poles_uniques {
			create Poles number: 1 {
				set mesAttracteurs <- list<Attracteurs>(currentPole);
				set shape <- convex_hull(polygon(mesAttracteurs collect each.location)) + 200; // Buffer de 200m autour du convex_hull
			}
		}
		
		loop cetAgregat over: Agregats {
			loop cePole over: Poles {
				if (dead(cePole)){break;}
				geometry cetAgregatShape <- cetAgregat.shape;

				if (cePole.shape intersects cetAgregatShape){
					set cetAgregat.monPole <- cePole;
					set cePole.shape <- cePole.shape + cetAgregatShape;
					set cePole.monAgregat <- cetAgregat;
					loop pole_a_absorber over: (Poles - cePole) {
						if (dead(pole_a_absorber)){break;}
						if (pole_a_absorber.shape intersects cePole.shape){
							set cePole.mesAttracteurs <- cePole.mesAttracteurs + pole_a_absorber.mesAttracteurs;
							set cePole.shape <- cePole.shape + pole_a_absorber.shape;
							ask pole_a_absorber {do die;}
						}
					}
				}
			}
		}
    	
		ask Poles {
			list<Eglises> mesEglises <- mesAttracteurs of_species Eglises;
			list<Chateaux> mesChateaux <- mesAttracteurs of_species Chateaux;
			list<Agregats> mesCommunautes <- mesAttracteurs of_species Agregats;
			set attractivite <- 0.0 ;


			switch length(mesEglises) {
				match 0 {set attractivite <- attrac_0_eglises;}
				match 1 {set attractivite <- attrac_1_eglises;}
				match 2 {set attractivite <- attrac_2_eglises;}
				match 3 {set attractivite <- attrac_3_eglises;}
				default {set attractivite <- attrac_4_eglises;} // 4 et +
			}
			
			if (length(mesChateaux) > 0){
				if ( (mesChateaux count (each.type = "Grand Chateau")) > 0){
					set attractivite <- attractivite + attrac_GC;
				} else {
					set attractivite <- attractivite + attrac_PC;
				}
			}
			if (length(mesCommunautes) > 0){
				set attractivite <- attractivite + attrac_communautes;
			}
		}
	}
			
}

	
species Attracteurs schedules: shuffle(Attracteurs) {
	int attractivite <- 0;
}

species Poles schedules: shuffle(Poles) {
	float attractivite;
	list<Attracteurs> mesAttracteurs;
	Agregats monAgregat;
}
