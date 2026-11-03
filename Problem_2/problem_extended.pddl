(define (problem mars-rover-extended)
  (:domain mars-rover)

  (:objects
    rover1 - rover
    base siteA siteB siteC siteD siteE siteF - location
    rock1 rock2 rock3 rock4 rock5 rock6 rock7 - sample
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
    (sample-at rock6 siteE)
    (sample-at rock7 siteF)

    ;; Storage Bays Initial State
    (empty rover1 bay1)
    (empty rover1 bay2)

    ;; Rock Types (Rock6 soft, Rock7 hard)
    (is-soft rock1)
    (is-soft rock2)
    (is-hard rock3)
    (is-soft rock4)
    (is-hard rock5)
    (is-soft rock6)
    (is-hard rock7)

    ;; Two-way Routes (Base <-> SiteB route removed due to dust storm)
    (connected base siteA) (connected siteA base)
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
      ;; All 7 samples delivered to Base
      (sample-at rock1 base)
      (sample-at rock2 base)
      (sample-at rock3 base)
      (sample-at rock4 base)
      (sample-at rock5 base)
      (sample-at rock6 base)
      (sample-at rock7 base)

      ;; Both storage bays emptied
      (empty rover1 bay1)
      (empty rover1 bay2)

      ;; Rover returned to Base
      (at rover1 base)
    )
  )
)