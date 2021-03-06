breed [balls ball ]

balls-own
[
  name
  speed 
  mass 
  momentum
]


globals [
 white-ball-mass
 red-ball-mass
 white-ball-speed
 
 M1
 M2
 INIT
 
 last-step
 
 done
 cue-collided 
 target-collided
 reversed
]



;; private
to-report __size [ms]
  report 1 + ms / 10
end

;; private
to-report get-by-name [i]
  report one-of balls with [name = i]
end




to make-ball [clr spd ms nm pos sz]
  create-balls 1 [
    set color clr
    set xcor  pos
    set speed spd 
    set mass ms
    set name nm
    set size sz
    set heading 90
    ]
end







to move [dist]
  if done = false [
    ask balls[forward speed * 0.025]
    check-done
  ]
end



to-report is-moving
  report speed != 0
end


to no-op
end


to-report close
  let b1 get-by-name "cue"
  let b2 get-by-name "target"
  
  let x1 [xcor] of b1
  let x2 [xcor] of b2
  let s1 [size] of b1
  let s2 [size] of b2
  let dd ((s1 + s2) * 0.5)
  let d abs(x1 - x2)
  
  ifelse (d <= dd) 
  [report true]
  [report false]
end


to-report moving-direction
  let b get-by-name "cue"
  report [heading] of b
end


to set-stationary-direction-same [direction]
  let b get-by-name "target"
  ask b [set heading direction]
end

to set-stationary-direction-reverse [direction]
  let b get-by-name "target"
  ask b [set heading direction * -1]
end


;; generic mass comparators
;; could be called from both perspectives:
;; e.g. stationary-me --> target-heavier, or
;; moving-other --> target-heavier
to-report cue-heavier
 report M1 > M2 
end

to-report target-heavier
 report M1 < M2 
end

to-report same-mass
 report M1 = M2 
end


to update-stationary-speed [new-speed]
  if target-collided = false [
    let b get-by-name "target"
    ask b [set speed new-speed]
    set target-collided True
    ]
end



;; stationary speed comparators
to-report stationary-same-other
  ;; correct block that should be used
  ;; when m1 == m2
 ; let b get-by-name "cue"
 ; report [speed] of b
  report INIT
end

to-report stationary-smaller-me
  ;; incorrect block that should not be called
  ;; speed can't be smaller than 0
  report 0
end


to-report stationary-same-me
  ;; incorrect block that should not be called
  ;; speed can't be smaller than 0
  report 0
end

to-report stationary-greater-me
  ;; correct block but shouldn't be used
  ;; that target's speed increases is a tautology 
  ;; returning a very slow speed
  report INIT / 10
end

to-report stationary-bigger-other
  ;; correct block that should be used 
  ;; when m1 > m2
;;  let m1 cue-ball-mass 
;;  let m2 target-ball-mass
  if M1 > M2 [report 2 * M1 * INIT / (M1 + M2)]
  ;; if used in the incorrect position
  ;; penalize by giving a fast speed that is impossible to reach
  report INIT * 2
end

to-report stationary-smaller-other
  ;; correct block that should be used
  ;; when m1 < m2
;;  let m1 cue-ball-mass 
;;  let m2 target-ball-mass
  if M1 < M2 [report 2 * M1 * INIT / (M1 + M2)]
  ;; if used in the incorrect position
  ;; penalize by giving a slower speed that doesn't change
  report INIT * 0.5
end

;;=============partition line=================

to update-moving-speed [new-speed]
  if cue-collided = false [
    let b get-by-name "cue"
    ask b [set speed new-speed]
    set cue-collided true
  ]
end

to set-moving-direction-same [direction]
  let b get-by-name "cue"
  ask b [set heading direction]
end

to set-moving-direction-reverse [direction]
  if reversed = false[
    let b get-by-name "cue"
    ask b [set heading direction * -1]
    set reversed true
  ]
end


;; moving speed comparators
to-report moving-same-other
  ;; correct block that should be used
  ;; when m1 == m2
  report 0
end

to-report moving-smaller-me
  ;; correct block that should be called
  ;; when m1 != m2
;  let m1 cue-ball-mass 
;  let m2 target-ball-mass

    report abs ((M1 - M2) * INIT / (M1 + M2))
end

to-report moving-greater-me
  ;; incorrect block that shouldn't be used
  ;; the cue shouldn't become faster anyhow
  report INIT * 4
end

to-report moving-same-me
  ;; correct but shouldn't be used
  report INIT
end


to-report moving-bigger-other
  ;; correct block but shouldn't be used 
  ;; only telling that the speed is greater than 0
  ;; so return a small speed 
  report INIT / 10
end

to-report moving-smaller-other
  ;; incorrect block that shouldn't be used
  report 0
end









to collide
   let b1 get-by-name "cue"
   let b2 get-by-name "target"
   

   let v1 [speed] of b1

   let v2 [speed] of b2

   ask b1 [
     set speed ((m1 - m2) * v1 + 2 * m2 * v2) / (m1 + m2)
   ]  
      
   ask b2 [
     set speed ((m2 - m1) * v2 + 2 * m1 * v1) / (m1 + m2)
   ]
end





to check-done
  if xcor >= max-pxcor[
    set done true
  ]
  if xcor <= min-pxcor[
    set done true
  ]
end











to before-run 
  ;clear-all
  
  ;;set INIT start-speed
  set-default-shape balls "circle"
  set done false
  set cue-collided false  
  set target-collided false
  set reversed false

  set M1 white-ball-mass
  set M2 red-ball-mass
  set INIT white-ball-speed
  ;;set cue-ball-mass mass-ratio
  ;;set target-ball-mass 4
  
  ;;make-ball [clr spd ms nm pos sz]
 ;; make-ball white 1 4 "cue" min-pxcor + 1 1 + cue-ball-mass / 10
  make-ball white white-ball-speed M1 "cue" min-pxcor + 1 1 + M1 / 10
  make-ball red 0 M2 "target" 0 1 + M2 / 10


  reset-ticks
 ; clear-all-plots
end


;; CTSiM bolierplates
to before-step
end

to after-step
  if done[
    stop
  ]
  tick
  
end

to update-view
end

to after-run
end
@#$#@#$#@
GRAPHICS-WINDOW
9
10
448
470
16
16
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

MONITOR
452
11
564
56
NIL
[speed] of ball 0
17
1
11

MONITOR
453
101
561
146
NIL
[mass] of ball 0
17
1
11

MONITOR
453
146
561
191
NIL
[mass] of ball 1
17
1
11

MONITOR
453
56
565
101
NIL
[speed] of ball 1
17
1
11

MONITOR
454
191
511
236
NIL
close
17
1
11

MONITOR
511
191
601
236
NIL
cue-collided
17
1
11

MONITOR
456
237
541
282
NIL
same-mass
17
1
11

MONITOR
457
285
544
330
NIL
cue-heavier
17
1
11

MONITOR
457
328
593
373
NIL
moving-smaller-me
17
1
11

MONITOR
458
375
625
420
NIL
stationary-bigger-other
17
1
11

MONITOR
603
190
708
235
NIL
target-collided
17
1
11

MONITOR
564
13
621
58
NIL
done
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
