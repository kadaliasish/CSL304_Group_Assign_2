(define (problem mars-rover-original)
  (:domain mars-rover)

  (:objects
    rover1 - rover
    base siteA siteB siteC siteD siteE siteF - location
    rock1 rock2 rock3 rock4 rock5 - sample
    bay1 bay2 - bay
    drill1 - drill
  )

  (:init
    ;; Initial Positions
    (base base)
    (at rover1 base)
    (drill-at drill1 siteE)
    (sample-at rock1 siteA)
    (sample-at rock2 siteB)
    (sample-at rock3 siteC)
    (sample-at rock4 siteD)
    (sample-at rock5 siteF)

    ;; Storage Bays Initial State
    (empty rover1 bay1)
    (empty rover1 bay2)

    ;; Rock Types (Soft vs Hard)
    (is-soft rock1)
    (is-soft rock2)
    (is-hard rock3)
    (is-soft rock4)
    (is-hard rock5)

    ;; Two-way Routes (Bidirectional Connectivity)
    (connected base siteA) (connected siteA base)
    (connected base siteB) (connected siteB base)
    (connected siteA siteC) (connected siteC siteA)
    (connected siteB siteD) (connected siteD siteB)
    (connected siteC siteE) (connected siteE siteC)
    (connected siteD siteE) (connected siteE siteD)
    (connected siteE siteF) (connected siteF siteE)

    ;; One-way Route (Steep Downhill Slope)
    (connected siteC siteD)
  )

  (:goal
    (and
      ;; All samples delivered to Base
      (sample-at rock1 base)
      (sample-at rock2 base)
      (sample-at rock3 base)
      (sample-at rock4 base)
      (sample-at rock5 base)

      ;; Both storage bays emptied
      (empty rover1 bay1)
      (empty rover1 bay2)

      ;; Rover returned to Base
      (at rover1 base)
    )
  )
)