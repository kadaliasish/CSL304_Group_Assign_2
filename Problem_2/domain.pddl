(define (domain mars-rover)

  (:requirements :strips :typing)

  (:types
    rover location sample equipment bay dri
    ll
  )
  
  (:predicates
    (at ?r - rover ?l - location)
    (sample-at ?s - sample ?l - location)
    (connected ?from - location ?to - location)
    (carrying ?r - rover ?s - sample ?b - bay)
    (empty ?r - rover ?b - bay)
    (is-hard ?s - sample)
    (is-soft ?s - sample)
    (drill-at ?d - drill ?l - location)
    (has-drill ?r - rover ?d - drill)
    (base ?l - location)
  )

  (:action move
    :parameters (
      ?r - rover
      ?from ?to - location
    )
    :precondition (and
      (at ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (at ?r ?from))
      (at ?r ?to)
    )
  )

  (:action pick-drill
    :parameters (
      ?r - rover
      ?d - drill
      ?l - location
    )
    :precondition (and
      (at ?r ?l)
      (drill-at ?d ?l)
    )
    :effect (and
      (has-drill ?r ?d)
      (not (drill-at ?d ?l))
    )
  )

  (:action collect-soft
    :parameters (
      ?r - rover
      ?l - location
      ?s - sample
      ?b - bay
    )
    :precondition (and
      (at ?r ?l)
      (sample-at ?s ?l)
      (is-soft ?s)
      (empty ?r ?b)
    )
    :effect (and
      (not (sample-at ?s ?l))
      (not (empty ?r ?b))
      (carrying ?r ?s ?b)
    )
  )

  (:action collect-hard
    :parameters (
      ?r - rover
      ?l - location
      ?s - sample
      ?b - bay
      ?d - drill
    )
    :precondition (and
      (at ?r ?l)
      (sample-at ?s ?l)
      (is-hard ?s)
      (empty ?r ?b)
      (has-drill ?r ?d)
    )
    :effect (and
      (not (sample-at ?s ?l))
      (not (empty ?r ?b))
      (carrying ?r ?s ?b)
    )
  )

  (:action deposit
    :parameters (
      ?r - rover
      ?s - sample
      ?l - location
      ?b - bay
    )
    :precondition (and
      (at ?r ?l)
      (base ?l)
      (carrying ?r ?s ?b)
    )
    :effect (and
      (not (carrying ?r ?s ?b))
      (empty ?r ?b)
      (sample-at ?s ?l)
    )
  )
)
