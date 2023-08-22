# TippingPigs

This is a project for a virtual toy/game that illustrates the concept of cascading tipping points to young people of ages 12-16 (e.g, tipping points in the climate system, but complex systems in general).

It is developed for the Max Planck Society for the History of Science & Max Planck Society for Geoanthropology by members of the ModelSEN project.

NOTE: This is an early version of the game. It is basically functional, but all art and UI elements are placeholders and game mechanics are unbalanced or still in development. 

## Overview
In the game, you take on the role of the head of a historical polynesian village on a pacific island. A crucial livestock which the
villagers are raising are pigs, who roam the island freely, eating the underbrush of the forests and grasslands to survive. The
villagers are similarly moving around in the forests, chopping trees. 

The island environment is fragile, though. If there is too much browsing by the pigs and too much chopping of wood,
the forests and grasslands degrade. If the degradation is too extensive, thresholds of the island's
hydrology and climate might be crossed, severly hampering the regrowth capabilities of the plant life.

Left unchecked, the increasing numbers of pigs will devestate the environment, rendering the island uninhabitable.

## How to play
(See below for a list of all keybindings)

The goal of the game is to achieve the highest score, which represents the villagers happiness, without destroying the island in the given timeframe (currently 2:30 minutes). 

On the island, pigs and villagers (currently depicted as fox-folk for random reasons) are roaming the island. The pigs eat underbrush, the villagers cut trees. 
Pigs will die if they don't find any underbrush to eat for too long. Villagers will flee the island if they are not able to harvest enough
wood for too long.

The pig herd is multiplying steadily. You can send away one pig to another island by pressing "S" or clicking the
"Schwein verschiffen"-Button. You can also press "D" or click the "Notfall-Festschmaus" button to slaughter half the island's pigs for a
feast. This option is only possible every 10 seconds, though.

There will be info-popups that come up when something notable happens needing your attention.

You can pause and unpause the game by pressing "E". This also gets rid of the infotexts.

Keep an eye on the tile tracker graphs on the right. There, you will be able to see en detail if and when a tipping point is crossed. There is
also information on the number of pigs, the amounts and percentages of the three tile-types (forest, grassland, desolation) as well as the average amounts
of the tiles' underbrush and tree cover values (ranging from 0-100) at the top of the screen.

At the top you also see your score as well as the current highscore. The score represents the happiness of the villagers and it is updating regularly
depending on the size of the pig herd, the percentage of forest tiles and the amount of wood stockpiled. If those numbers are very low, the score can also
go down! The highest score you got will count, though, if you still manage to end the run successfully, albeit with potential downgrades depending on the state of your
environment. 

The game can end in a number of ways. If your island survives the countdown, you have beaten the game and your score gets recorded. The game can end prematurely
with a gameover if one of the two following scenarios occurs: 
	I) the island environment collapses (100% desolation tiles),
	II) the pig herd gets uncontrollably big (>= 300 pigs)
In both cases, your score does not get recorded and your run is regarded as failure. 
If you manage to beat the game, but your environment is on its way to collapse by the time the countdown ended, your score will get a heavy downgrade. 

### Keybindings
"E" - pause/unpause and close infotexts
"Q" - restart the game
"Esc" - end and close the game

"S" - send away 1 pig
"D" - prepare half of all pigs for feast
"F" - spawn 1 pig
"G" - spawn 10 pigs

## Historical and Scientific background
...
include literature, explanation of why islands etc. ... the current is just a draft with some collected thoughts.
...
The socio-biogeography of pacific islands during the polynesian settlement has been an area of study
for a number of decades. It is presumed that a relatively homogenous group of people - the historical
polynesians - settled the area of modern day polynesia in a comparatively short period of time (according to 
current estimates between 800-1300 CE, mostly). The islands they settled on varied in climate, topology, and geological history,
but many have a lot in common due to their small size, relative remoteness, and common biological history. 
Due to these features, the area and epoch have been regarded as unusually suited for comparative historical analyses and the study of historical human-environmental interactions. 

The historical polynesians that explored and settled the area are thought to have had a similar set of
cultural practices, beliefs, social organization, as well as a common set of agricultural tools, practices, crops, and
- most importantly for us - livestock. Among that, the house pig had a very special role for polynesian agriculture as well
as for many cultural, political, and religious practices. 

It was an important protein source (next to other, smaller livestock, fish, and birds) but most importantly 
was a symbol of wealth and influence that was shown off, traded, and used to demonstrate hierarchy and
loyalty.

Curiously though, it seems that on a lot of polynesian islands, pigs were at some point abandoned as 
a livestock entirely. There is ample debate on if that was a deliberate process or an accident, but at 
least on some islands there is strong evidence that this has been a step to limit the destructive effect that pigs had on the natural
envioronment of some islands - pigs were often left browsing the islands, which sometimes had devestating
effects on the regrowth of the plant life and - together with other agricultural and cultural practices -
led to the degradation of areas and, in some cases, perhaps complete islands. 

Due to this unique coupling of social and environmental processes that in some historical cases
have led either to a successful adaptation and management of resources or the galloping destruction of
the islander's livelihoods, and due to the limited scope of small and remote islands,
we thought that this setting might be a good fit especially for younger people to grasp the dynamics of social-environmental
systems interactions such as tipping points.

The most obvious and much-discussed example of tipping points - those in the global climate and its subsystems -
seemed to us more abstract and less easy to grasp in comparison. It also might dissuade some people to engage with
climate tipping points by being too acute to the point of feeling threatening or scary. Still, understanding the related
concepts and actual dynamics is hugely important for this generation to be able to (and feel able to) react
to the imminent changes that the changing climate is producing.

The whole planet is the scope of the problem, which is not only harder to understand intuitively but also harder to
model engagingly in a virtual environment. Additionally, the people and environments that are actually affected would not be visible
immediately and would probably have to be abstracted. Having people in a model such as this presumably makes an intuitive and emotional
understanding easier, and thereby making the actual dynamics and scientfic principles behind
tippings points more palatable. 

This is also helped in the TippingPigs game by the name-giving pigs. Their inherent cuteness and
familiarity make them a good additional emotional anchor if environmental effects on grown-up humans
is too abstract.

Reasons for choosing this scenario for a tipping points game:
	- the smaller scope in comparison to planetary dynamics, while still mirroring similar social-environmental dynamics on a smaller scale 
	- the historical character might make it less scary to some, assome might be turned away by too acute topics)
	- humans as visible parts of the dynamics
	- pigs as likeable intermediaries 
	- evocative setting of tropical islands that is known in some capacity by many (through classic stories like "Treasure Island", "The mutineers of the Bounty", or new stories such as Disney's "Moana")

### Some challenges

While being a good fit to teach about tipping points in our opinion, this setting carries a number of challenges, for a european team with 
limited resources especially.

Firstly, from a historical standpoint, the source material that is the basis for many of the interpretations
of early polynesian history is limited. Most sources are the product of archaeological digs, while some information
is also inferred from the surviving oral history of many islands. Another set of sources are accounts and depictions by
european explorers and colonizers. It is always a risk to display a simplified version of history in media,
but with such a source base that is open to many interpretations this problem is amplified. At the same time,
because this game is aimed at and will be played by a predominantly German audience, the perspective of 
the players will already be framed by the cultural stereotypes and images that 

Secondly, the view of this setting is necessarily influenced by colonial history, due to the team not being from the region
and, as was just said, much of the source material either directly coming from europeans, being heavily influenced by 
europeans, or just by being a result of research conducted by people of european decent. This means that a lot of care should be put into 
avoiding stereotypes and simplistic notions of the historical as well as the current inhabitants of Polynesia (such as the topos of "noble savages" or others). 
Ideally, the project should have consulted with one or more persons knowledgable in the history and identity of people of the
area to avoid reproducing stereotypes to a younger audience. Unfortunately, as of yet, this was not
possible within the scope of this project. However, we hope that by relying on scientific accounts and being mindful of 
typical or colonial-romantic notions of the area for the most part, we were somewhat successful in avoiding such
problems. 

It has to be pointed out though that we definitely do play with some of the romantic notions of beautiful
tropical islands through the imagery and the feel we are trying to create. We still hope and definitely intend that this is
more reflecting the objective beauty of many of the islands as historically and socially formed places, and is not
reflecting our stereotypes of an ahistoric, presupposed "natural beauty" of pacific islands. It is also
limited to the environmental aspects of the game and is explicitely not employed for the people living
on them - which might have resulted in some of the abovementioned stereotypes). This is also
the point we hope to get accross for the players interacting with the game, through the historical
and matter-of-fact depiction as well as the contextualizing info-popups.

Other, more practical challenges include:
	- lack of a team with different expertises:
		- lack of expertise in game/learning game development (balancing teaching goals with fun; understanding how fun works; experience in gamedev workflows)
		- lack of didactical expertise
		- lack of artistical expertise
	- unique use case (short engagement in learning convention; unlike typical (learning) games -> less time and space to teach in the game, limits on complexity of game mechanics, ...)
	- ...




## In-depth mechanics
...
Explanation of how the environment and agent interactions + dynamcis work, exactly.
...

NOTE: All values / thresholds etc. may be subject to change, so the details/values can be outdated.

### The Island Environment
The island consists of tiles of three types: forest, grassland, and desolation. The type of the tile
is determined by its properties "underbrush" and most importantly "tree cover", both go from 0 to 100. If the tree cover value sinks
below a threshold, the tile becomes grassland or - if the tree cover is gone completely - desolation.
Desolation ceases to be useful for villagers and pigs, and also negatively impacts surrounding tiles.

The tree cover regrows depending on: 
	I) the underbrush value - the higher the value, the better the tree growth;
	II) surrounding desolation tiles - the more desolation tiles, the worse the tree growth;
	III) global thresholds of plant growth

In turn, high levels of tree cover lead to higher underbrush growth. Both Tree cover and underbrush level have
three thresholds that determine the other levels growth. The upper third leads to good growht, the middle
third leads to stagnation, and the low third leads to sharp decline. This way, an escalating domino effect should
happen if one or the other value gets to low or - in the case of stagnation - if there
is outside pressure by pigs and villagers.

The surrounding desolation tiles impact tiles in an escalating way as well, depending on their number.
If there are no more than 2 desolation tiles around, only mild negative effects occur. 3 and higher lead to
more noticable effects, while 6 and above almost certainly lead to collapse. This should lead to
another tipping point and cascading collapse of tiles that are too vulnerable.

The global thresholds for plant growth are passed if the global average tree cover gets below
certain points (66, 50, and 33 % coverage). In those cases, all plant growth gets a debuff that
rises with each threshold. This is both a way to push the whole island to collapse more quickly,
for gameplay reasons, but also is a standin / representation of island wide effects on
hydrology and climate that would occur. If the first threshold is passed, the player should have
some limited leeway left to react/adapt - it should be possible to survive still if pigs are kept
to a minimum or are even exterminated entirely. After the second, the island is collapsing. The 
third is mainly there to speed things up once the gameover is on the horizon and the player can't
really do anything anymore.

### The "agents" - pigs and villagers

#### Pigs
Pigs have "hunger" and "health" values. They eat underbrush off of tiles to decrease hunger. If they 
don't find enough underbrush and the hunger stays high for too long, they lose health. If they loose
all their health, they die. 
Pigs roam around randomly. After they ate underbrush, they move to a different, random tile near them.
There they eat again.

#### Villagers
Villagers have a "health" value as well (representing their mood, more than their healt). Their health is
impacted by the woods supply they gathered, if it runs too low. If they deplete their health,
they "die", ie., they leave the island. They regain health if the wood stockpile is high enough.

Villagers roam around randomly similar to the pigs, but they cut trees for wood. The wood stockpile is
capped. Currently, no wood consumption takes place.



## Developers
Current:
Jascha Schmitz
Former:
---

## Literature
