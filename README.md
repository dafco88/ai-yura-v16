# AI-YURA v16 — résultats

AI-YURA est un programme de recherche indépendant sur l'**apprentissage continu** : un modèle qui
apprend des domaines successifs sans oublier les précédents, et qui se ré-entraîne seul sans jamais
régresser. Ce dépôt présente les **résultats mesurés**. Le code et la méthode restent privés.

> 🧪 Tester les modèles : **[dafco88/ai-yura-seeds](https://github.com/dafco88/ai-yura-seeds)**

> ⚠️ **Révision du 13.09.2026 — retrait des mesures vision.** Un défaut de protocole découvert le
> 12.09.2026 (une paire de classes n'était jamais apprise par le banc) invalide toutes les mesures
> **vision** publiées ici auparavant, ainsi que les chiffres agrégés qui en dérivaient. Elles sont
> retirées **sans être remplacées** : la re-mesure sous protocole corrigé est en cours et rien ne sera
> republié avant la fin des campagnes en cours. Les mesures **texte** ne sont pas concernées par ce
> défaut et ont été remesurées sous le protocole corrigé (83,1 ± 1,6 sur 6 graines, contre
> 82,3 ± 1,3 sur 3 graines auparavant). Les résultats de la porte de promotion (§4) et les preuves
> Lean (§4bis) sont indépendants de ce banc et inchangés.

> ✏️ **Correction du 15.09.2026.** Les versions précédentes présentaient les « 20 Ko » de la méthode face
> aux « 2 Mo » du rejeu de données comme une comparaison de mémoire. Ce n'est vrai que pour les
> **données stockées** : en empreinte totale, AI-YURA occupe davantage de mémoire (§1, registre complet).

## En bref

Chiffres tenus sur 6 graines (protocole corrigé, conditions mesurées dans la même session) :

- Rétention **texte** de **83,1 %** de santé en fin de séquence, **sans conserver aucune donnée
  d'origine**, avec 20 Ko de données stockées, contre 2 Mo pour le rejeu de données de référence.
  La méthode garde en revanche 28 Mo de copies du modèle : empreinte totale 118 Mo contre 91 Mo (§1).
- Sans le composant central de la méthode — la **consolidation multi-échelle** : **−18,7 points
  en texte**, sur 6 graines sur 6. La protection est nécessaire, pas décorative.
- Le second composant se décompose : c'est la **distillation** qui porte la rétention texte, et elle en
  garde l'essentiel même sur des entrées tirées au hasard. Le générateur n'ajoute qu'environ 6 points
  sur 39 (§5).
- **Écart défavorable mesuré et assumé** : remplacer l'optimiseur du projet par AdamW donne
  **86,1 ± 0,5** en texte contre **83,1 ± 1,6** pour le témoin, sur les mêmes 6 graines. Sur ce
  banc, l'optimiseur maison coûte de la rétention (§7).
- Sur un **banc simulant** 60 nuits de ré-entraînement, la dérive de qualité reste bornée à
  **×1,07 à ×1,10**, contre ×39,7 à ×58,0 pour une porte de promotion classique (§4).
- En production, le 29.08.2026, une régression réelle (perplexité 32,5 contre 20,9) a été **rejetée
  automatiquement** et le champion restauré, sans intervention humaine.

## 1. Oubli en texte

Banc multimodal, 1,86 M de paramètres, tâches texte et vision enchaînées, 6 graines, protocole
corrigé du 12.09.2026. Santé en fin de séquence, en % (haut = mieux).

| | Texte | Données stockées |
|---|---|---|
| Sans protection | 18,7 ± 6,3 | 4,6 Ko |
| Rejeu avec données (référence) | 95,7 ± 0,8 | 2,0 Mo |
| **AI-YURA (aucune donnée d'origine)** | **83,1 ± 1,6** | **20 Ko** |
| AI-YURA sans consolidation multi-échelle | 64,4 ± 0,4 | 20 Ko |
| AI-YURA avec AdamW au lieu de l'optimiseur du projet | 86,1 ± 0,5 | 20 Ko |

*La colonne vision de ce tableau a été retirée le 13.09.2026 (voir l'avertissement en tête). Le banc
reste multimodal ; seules les mesures vision sont suspendues.*

*Réserve de lecture : la santé est mesurée par rapport à ce que chaque condition a appris juste après
chaque tâche. La méthode apprend chaque domaine moins finement que les autres conditions ; une partie
de la rétention mesurée reflète donc un compromis entre stabilité et plasticité.*

### Registre complet de la mémoire

« 20 Ko » ne compte que les données. Mesuré sur le banc lui-même (float32) :

| Poste | Sans protection | Rejeu de données | AI-YURA |
|---|---|---|---|
| Poids du modèle | 7,4 Mo | 7,4 Mo | 7,4 Mo |
| Professeur figé | — | — | 7,4 Mo |
| Ancres de consolidation (3 copies du tronc) | — | — | 22,2 Mo |
| État de l'optimiseur (commun) | 81,1 Mo | 81,1 Mo | 81,1 Mo |
| Données et prototypes stockés | 4,6 Ko | 2,0 Mo | 20 Ko |
| **Empreinte totale** | **88,5 Mo** | **90,5 Mo** | **118,2 Mo** |

L'avantage de la méthode est de ne conserver **aucune donnée d'origine**, pas d'être plus sobre.
L'état d'optimiseur est celui de l'optimiseur maison (10 gradients passés) ; AdamW en garderait ≈ 15 Mo.

### À nombre d'exemples égal

Rejeu de données limité à 120 séquences texte (autant que le pool généré d'AI-YURA) et à un petit
tampon d'images, mêmes lots, même session, 12.09.2026. Santé texte, par graine :

| Graine | Rejeu, 332 Ko | AI-YURA | Écart | Rejeu, 529 Ko | AI-YURA | Écart |
|---|---|---|---|---|---|---|
| 0 | 40,8 | 82,0 | +41,2 | 40,9 | 82,0 | +41,1 |
| 1 | 42,2 | 81,5 | +39,3 | 43,2 | 81,4 | +38,2 |
| 2 | 42,1 | 82,3 | +40,2 | 41,8 | 82,1 | +40,3 |
| 3 | 45,1 | 83,3 | +38,2 | 45,5 | 83,6 | +38,1 |
| 4 | 40,8 | 85,5 | +44,7 | 45,0 | 85,5 | +40,5 |
| 5 | 42,9 | 83,6 | +40,7 | 40,9 | 82,8 | +41,9 |

La prédiction écrite avant les runs (« le rejeu fait aussi bien ») est réfutée. **L'égalité porte sur le
nombre d'exemples, pas sur la mémoire** : AI-YURA garde en plus 28 Mo de copies du modèle. Un rejeu doté du
même registre complet n'a pas été testé. Ce tableau ne prouve pas non plus que des données générées valent
mieux que des données réelles.

## 2. Champion texte

Modèle de continuation de texte, ré-entraîné par phases. Chaque phase repart des poids de la
précédente, jamais de zéro. Perplexité (bas = mieux).

| Phase | Date | Perplexité moyenne | Cas validés |
|---|---|---|---|
| Phase 1 | 18.07.2026 | 254,0 | 13/15 |
| Phase 2 | 19.07.2026 | 140,4 | 15/15 |
| Phase 3 | 16.08.2026 | 59,0 → 44,4 | 15/15 |
| Phase 4 | 17.08.2026 | 30,6 | 15/15 |
| Phase 5 | 18.08.2026 | 25,3 | 12/12 |
| **Apprentissage autonome — champion** | **18.08.2026** | **20,9** | **12/12** |
| Apprentissage autonome — rejeté par la porte | 29.08.2026 | 32,5 | rollback automatique |

Détail du champion du 18.08.2026 :

| Domaine | Perplexité |
|---|---|
| dialogue | 1,24 |
| logique | 10,19 |
| philosophie | 12,29 |
| mathématiques | 20,28 |
| français | 20,52 |
| sciences | 24,63 |
| TinyStories | 24,70 |
| histoire | 26,70 |
| Shakespeare | 33,15 |
| code | 34,85 |
| **moyenne** | **20,86** |

Plus deux cas de génération validés (français, histoire en anglais), soit 12/12.

**Septembre 2026 — deux campagnes de 4 cycles sur 3 graines**, porte appliquée en mode informatif (seuil
de promotion 22,94) : aucun candidat ne passe.

| Graine | Optimiseur AdamW | Optimiseur du projet |
|---|---|---|
| 42 | 25,73 | 26,62 |
| 123 | 29,42 | 24,05 |
| 7 | 24,97 | 23,65 |
| moyenne | 26,71 ± 2,38 | 24,77 ± 1,61 |

Écart moyen −1,9 ± 3,2 en faveur de l'optimiseur du projet, sur 2 graines sur 3 seulement : non concluant.
Les candidats dégradent tous Shakespeare (46 à 55) et le code (44 à 48).

*Portée de ces chiffres : une seule graine par phase, corpus et tokenizer propres au projet. Ils mesurent
la progression interne de la lignée ; ils ne sont comparables à aucune perplexité publiée ailleurs.*

## 3. Ophan — seed multimodale texte + vision (retirée)

*Chiffres retirés le 13.09.2026.* Les perplexités et taux vision publiés pour les trois graines ne
sont pas défendables en l'état : les sondes texte peuvent provenir du flux d'entraînement, et
l'évaluation vision reposait sur 36 images au total (une image = 2,78 points). Cette seed documente
une naissance de modèle, pas un résultat d'apprentissage continu. À remesurer avec un jeu
d'évaluation disjoint et de taille suffisante avant toute republication.

## 4. Porte de promotion

**Simulation** de 60 nuits de ré-entraînement, candidats qui dérivent de +9 % par promotion, tolérance
×1,10, 3 graines.

| Porte | Dérive finale | Borne ×1,10 respectée |
|---|---|---|
| Classique (compare au dernier champion) | ×39,7 à ×58,0 | 0/3 |
| Pondérée par l'historique | ×1,10 à ×1,16 | 1/3 |
| **AI-YURA** | **×1,07 à ×1,10** | **3/3** |

En production : rejet réel du 29.08.2026 (§2), puis aucun candidat promu lors des campagnes de septembre.

## 4bis. Résultats formels vérifiés mécaniquement (Lean 4)

Le comportement de la porte n'est pas qu'un résultat de simulation : il découle de deux théorèmes simples,
**vérifiés par Lean 4.33.1**, sans Mathlib, sans `sorry` ni `axiom`. L'algèbre utilisée (un semi-anneau
ordonné) est déclarée explicitement, et une instance concrète sur les entiers naturels montre qu'elle
n'est pas vide. Fichiers dans [`preuves/`](preuves/).

| Fichier — énoncé | Résultat | Portée |
|---|---|---|
| `SafetyGate.lean` — théorème 2 | Porte **dépendante du chemin** (référence = dernier état accepté, seuil τ par tour) : la seule garantie au tour n est **sₙ ≥ τⁿ · s₀**, qui se dégrade géométriquement | résultat principal |
| `SafetyGate.lean` — théorème 1 | Porte **ancrée** (référence = état initial) : **sₙ ≥ τ · s₀ à tout tour**, indépendamment de la longueur | découle directement de la règle ; sert de contraste |
| `Consolidation.lean` — théorème 3 | Contrainte **par pas** ≤ c : dérive cumulée ≤ **n · c** | borne croissante avec le temps |
| `Consolidation.lean` — théorème 4 | Contrainte **à distance de l'origine** ≤ B : borne **B** à tout tour | constante en n |
| `Consolidation.lean` — théorème 5 | Mémoire à **moyenne mobile exponentielle** : la contribution de l'état initial est ≤ **rⁿ** | effacement géométrique |

Lecture : une référence **ancrée** donne une garantie constante, une référence **dépendante du chemin**
une garantie qui s'érode à chaque tour. La simulation du §4 en est l'illustration numérique.

**Ce qui n'est PAS établi** : la convergence rⁿ → 0 (analyse réelle non formalisée) ; qu'une référence figée
soit préférable en général (elle borne l'oubli mais aussi l'apprentissage) ; la correspondance exacte entre
ces énoncés et une implémentation donnée, qui reste une hypothèse de modélisation.

Vérifier soi-même : `cd preuves && lake build` (Lean 4.33.1 via `elan`, quelques secondes).

## 5. Décomposition du signal génératif — rejeu contre distillation

Plan factoriel 2 × 2 sur les deux termes du composant génératif (rejeu des séquences générées,
distillation d'un professeur figé sur ces séquences), 6 graines, protocole corrigé, 13-14.09.2026.
Santé texte en fin de séquence, en % (haut = mieux).

| Condition | Texte | Δ contre témoin | Classification pré-enregistrée |
|---|---|---|---|
| **Témoin** — rejeu + distillation | **82,8 ± 1,5** | — | référence |
| Distillation seule | 83,5 ± 2,2 | +0,66 | indistinct |
| Rejeu seul | 76,4 ± 1,7 | −6,43 | DÉGRADE |
| Ni l'un ni l'autre | 44,5 ± 1,5 | −38,36 | DÉGRADE |

L'effet du terme de rejeu dépend entièrement de la présence de la distillation :
**+31,9 points sans elle, −0,7 point avec elle**. Les deux mécanismes ne s'additionnent pas,
ils se recouvrent — et c'est la distillation qui porte la rétention texte.

### Et le générateur lui-même ?

Le pool généré est à 97-99 % hors de la grammaire des domaines — pourtant la distillation sur ce pool
porte 39 points de texte. Campagne du 14.09.2026 : distillation seule, pool généré contre pool
d'identifiants tirés uniformément dans le vocabulaire (même nombre de séquences, même longueur, même
amorce balisée), 6 graines.

| Distillation seule, sur… | Texte | Écart |
|---|---|---|
| un pool **généré** | 83,5 | — |
| un pool **aléatoire** de même forme | 77,1 | −6,37, sur 6/6 graines (t = −5,8) |
| *rien* (report du tableau ci-dessus) | 44,5 | −39,0 |

Verdict pré-enregistré : *générateur utile*. Mais **sur les ~39 points que porte la distillation, ~33
sont obtenus avec des entrées tirées au hasard, et ~6 seulement viennent du générateur.** La formulation
exacte devient : *distillation sur pseudo-entrées auto-générées, sans aucune donnée stockée*. Nous ne
revendiquons pas de « mémoire générative » de contenu.

*Réserve de lecture : les ~39 points croisent deux campagnes (écart de 0,01 sur la cellule commune) ;
chiffre indicatif plutôt qu'établi. Le témoin de ce tableau (82,8 ± 1,5) et celui du §1 (83,1 ± 1,6)
viennent de deux campagnes du même protocole ; écart dans le bruit inter-campagne.*

### Force de consolidation

Carte complète de la force de consolidation, en fraction du réglage par défaut, 6 graines par point
(13.09.2026). Santé texte :

| Force | 0 | 5 % | 12,5 % | 25 % | 50 % | 100 % (défaut) |
|---|---|---|---|---|---|---|
| Texte | 64,4 | 75,4 | 84,9 | **86,5** | 85,9 | 83,1 |

Pas de falaise : une consolidation résiduelle récupère l'essentiel ; l'optimum texte est intérieur
(25 %, +3,4 points sur 6/6 graines). La vision sans données demande au contraire une consolidation forte
(lectures non publiées tant que la re-mesure n'est pas close) : un seul réglage ne sert pas les deux
modalités. **Candidat non adopté** : jamais combiné avec AdamW, confirmation conjointe requise.

## 6. Consolidation suspendue pendant la première tâche — écartée

Levier testé le 14.09.2026 : suspendre la chirurgie de consolidation pendant la première tâche
seulement. Témoin et levier entrelacés, **12 graines** (6 puis 6 de réplication).

| Lecture | Résultat |
|---|---|
| Perplexité finale, arithmétique / algèbre / latin | **9,41 → 6,11 · 5,19 → 3,25 · 4,11 → 3,59**, plus basse sur 12/12 graines dans les trois domaines |
| Santé texte | +1,4 en moyenne (mieux sur 8/12) |
| Lectures vision | recul sur 10 graines sur 12 : coût **établi** selon la règle pré-enregistrée |

Sur 6 graines, le levier paraissait gratuit ; la réplication sur 6 graines de plus a confirmé le gain texte
et établi le coût vision. **C'est un arbitrage texte/vision, pas un gain : levier non adopté.**

## 7. Limites connues

- **Vision : aucune mesure publiée à ce jour.** Le banc vision a tourné sous un protocole défectueux
  du 07.08 au 12.09.2026 ; les chiffres correspondants ont été retirés et la re-mesure est en cours.
- **Mémoire** : la méthode ne stocke pas de données, mais son empreinte totale dépasse celle du rejeu de
  données (118 Mo contre 91 Mo, §1). Aucun rejeu à registre complet égal n'a été comparé.
- **L'optimiseur du projet n'est pas justifié par ce banc.** À protocole identique et 6 graines,
  AdamW fait mieux que lui en texte (86,1 ± 0,5 contre 83,1 ± 1,6) et en santé globale.
- **Le pilote autonome du 11-12.09.2026 n'est pas exploitable.** Trente configurations explorées,
  aucune adoptée — mais la moitié vision de son score de décision a été mesurée sous le protocole
  défectueux (la tâche vision la plus ancienne n'était jamais évaluée). Les 30 décisions sont à refaire.
- La rétention texte est une santé relative (voir la réserve du §1) : elle ne dit pas à elle seule
  quelle condition atteint la meilleure perplexité absolue en fin de séquence.
- Le champion texte n'a pas été remplacé depuis le 18.08.2026 : les domaines code, Shakespeare et
  TinyStories font échouer les candidats.
- Les résultats à une seule graine sont traités comme des directions, jamais comme des conclusions.
- Aucune comparaison à une méthode publiée n'a été exécutée dans ce harnais à ce jour. Les chiffres
  ci-dessus mesurent des écarts internes entre conditions, pas une position dans l'état de l'art.

## Licence

Tous droits réservés. Voir [LICENCE.md](LICENCE.md).
