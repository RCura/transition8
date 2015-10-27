/**
 *  T8
 *  Author: Robin
 *  Description: Les agglomérations sont des agents "persistants", mais dont on vérifie l'existence à chaque pas de temps.
 */

model t8

import "../init.gaml"
import "../global.gaml"
import "Foyers_Paysans.gaml"
import "Chateaux.gaml"
import "Eglises.gaml"
import "Seigneurs.gaml"
import "Attracteurs.gaml"
import "Zones_Prelevement.gaml"

global {
	
	
	action update_agregats {
    	list<list<Foyers_Paysans>> agregats_detectees <- list<list<Foyers_Paysans>>(simple_clustering_by_distance(Foyers_Paysans, distance_detection_agregats) );
    	agregats_detectees <- agregats_detectees where (length(each) >= nombre_FP_agregat);
    	
    	ask Foyers_Paysans {
    		set monAgregat <- nil ;
    	}
   		// 2 - On parcourt la liste des anciennes agglos
   		loop ancienAgregat over: Agregats {
   			bool encore_agregat <- false;
   			loop nouvelAgregat over: agregats_detectees {
   				list<Foyers_Paysans> FP_inclus <- nouvelAgregat;
   				geometry geom_agregat <- convex_hull(polygon(FP_inclus collect each.location));
   				if (ancienAgregat.shape intersects geom_agregat){
   					ask ancienAgregat {
   						set fp_agregat <- FP_inclus;
   						ask fp_agregat {
   							set monAgregat <- myself ;
   						}
					set monChateau <- ancienAgregat.monChateau;
					ask monChateau {
						set monAgregat <- nouvelAgregat as Agregats;
					}
					do update_shape;
					if (Annee >= apparition_communautes){do update_comm_agraire;}
   					}
					agregats_detectees >> nouvelAgregat;
					set encore_agregat <- true;
					// sortir de la boucle j
					break;
   				}
   			}
   			if (!encore_agregat) {
				ask ancienAgregat { do die;}
				ask (Chateaux where (each.monAgregat = ancienAgregat)) {set monAgregat <- nil;}	   				
   			}
   		}
   		loop nouvel_agregat over: agregats_detectees {
   			create Agregats {
   				set fp_agregat <- nouvel_agregat;
   				ask fp_agregat {
   					set monAgregat <- myself;
   				}
   				do update_shape;
   				if (Annee >= apparition_communautes){do update_comm_agraire;}
   			}
   		}
    }
}

entities {

	species Agregats parent: Attracteurs schedules: shuffle(Agregats){
		bool fake_agregat <- false;
		int attractivite <- 0;
		list<Foyers_Paysans> fp_agregat ;
		bool communaute <- false;
		bool marche <- false;
		Chateaux monChateau <- nil;
		bool reel <- true;
		
		action update_chateau {
			// FIXME : Chateaux trop proches sinon
			
			if (monChateau = nil or (self distance_to monChateau > 1000)) {
				list<Chateaux> Chateaux_proches <- Chateaux at_distance 1000;
				if (empty(Chateaux_proches)) {
					monChateau <- nil;
				} else {
					monChateau <- Chateaux_proches with_min_of (each distance_to self);
				}
			}
		}
		
		action update_shape {
			set shape <- convex_hull(polygon(fp_agregat collect each.location));
		}
		
		action update_attractivite {
			// Temporairement désactivé
			//set attractivite <- length(fp_agregat) +  sum(Chateaux where (self = each.monAgregat) collect each.attractivite);
			set attractivite <- length(fp_agregat);
		}
		
		
		action update_comm_agraire {
			if (!self.communaute) {
				if (flip(proba_apparition_communaute)) {
					set communaute <- true;
					ask self.fp_agregat {
						set communaute <- true;
					}
				} else {
					ask self.fp_agregat {
						set communaute <- false;
					}
				}
			} else {
				ask self.fp_agregat {
					set communaute <- true;
				}
			}
		}
		
		
	}
}