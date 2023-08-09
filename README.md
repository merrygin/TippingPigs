# TippingPoints

This is a project for a virtual toy/game that illustrates the concept of cascading tipping points to children of ages 12-16 (see for example [Tipping Points in the climate system](https://en.wikipedia.org/wiki/Tipping_points_in_the_climate_system)). 

It is developed for the Max Planck Society for the History of Science & Max Planck Society for Geoanthropology by members of the [ModelSEN project](https://en.wikipedia.org/wiki/Tipping_points_in_the_climate_system).


**How to play:**
On the island, pigs and villagers (currently depicted as fox-folk) are roaming the island. The pigs eat underbrush, the villagers cut trees. Pigs will die if they don't find any underbrush to eat for too long. 

Currently, you can interact with the game by pressing the buttons at the bottom of the screen to spawn or cull pigs or by pressing "F". You can also press "G" to spawn 10 pigs at once. 

There are also Infotext-Popups that come up when something notable happens.

You can pause and unpause the game by pressing "E". This also gets rid of the infotexts.

Keep an eye on the 

[MORE INFO ON THIS PROJECT COMING ... AT SOME POINT]

Current Developers:
Jascha Schmitz

Past Developers:


TODO (more detail: designdoc on nextcloud...):
	
	
CHECK make forest regrow
	faster with more trees around
	normal neighborhood (4 sided), because 8 sided probably too resource intensive? 
	-> its 8 sided/moore now
CHECK make pigs notice if target unreachable.
	should factor that in already at decision moment, so they don’t even try to get clogged up at the shore
	should STILL be able to abort if it takes too long
CHECK make grassland die off too, preventing any regrowth (unless… enough grassland around. so again some kind of all-around check algo)

make pigs die/get sad when hungry too long 
make villagers?!
	need/use forest too
	are happy with more pigs
	are unhappy with not enough forest
	what about cropland?!
balancing
map camera restriction + camera movement
data visibility and graphs
art/animations
