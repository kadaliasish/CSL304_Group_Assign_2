:- use_module(library(lists)).

% Step 1: Predicate logic representation
%
%   A1. archivist(X) ∧ verifies(X,R) → trusted(X)
%   A2. trusted(X) ∧ has_access(X,R) ∧ sealed(R) → permitted_to_inspect(X,R)
%   A3. inspects(X,R) ∧ finds_mark(X,R) → verifies(X,R)
%   A4. stored_in(R, royal_archive) → sealed(R)
%   F5. stored_in(scroll_7, royal_archive)
%   F6. has_access(mira, scroll_7)
%   F7. inspects(mira, scroll_7)
%   F8. finds_mark(mira, scroll_7)
%   F9. archivist(mira)
%
% Step 2: Negation of goal
%
%   Goal: trusted(mira)
%   Negate: ¬trusted(mira)
%
% Step 3: Implication removal  (P → Q  becomes  ¬P ∨ Q)
%
%   A1. ¬archivist(X) ∨ ¬verifies(X,R) ∨ trusted(X)
%   A2. ¬trusted(X) ∨ ¬has_access(X,R) ∨ ¬sealed(R) ∨ permitted_to_inspect(X,R)
%   A3. ¬inspects(X,R) ∨ ¬finds_mark(X,R) ∨ verifies(X,R)
%   A4. ¬stored_in(R,royal_archive) ∨ sealed(R)
%   F5–F9, CN: already atomic
%
% Step 4: Negation movement
%
%   No nested negations; all literals already in ¬atom or atom form.
%
% Step 5: Standardization
%
%   Each clause uses its own variable names; no sharing across clauses.
%
% Step 6: Skolemization
%
%   No existential quantifiers present; nothing to Skolemize.
%
% Step 7: CNF clauses
%   Each formula is already a single disjunction of literals (one clause).
%   Represented below as clause_template/2 lists.
%   pos(P,Args) = positive literal P(Args), neg(P,Args) = ¬P(Args)

clause_template(c1, [neg(archivist,[X]), neg(verifies,[X,_R]), pos(trusted,[X])]).
clause_template(c2, [neg(trusted,[X]), neg(has_access,[X,R]), neg(sealed,[R]), pos(permitted_to_inspect,[X,R])]).
clause_template(c3, [neg(inspects,[X,R]), neg(finds_mark,[X,R]), pos(verifies,[X,R])]).
clause_template(c4, [neg(stored_in,[R,royal_archive]), pos(sealed,[R])]).
clause_template(c5, [pos(stored_in,[scroll_7,royal_archive])]).
clause_template(c6, [pos(has_access,[mira,scroll_7])]).
clause_template(c7, [pos(inspects,[mira,scroll_7])]).
clause_template(c8, [pos(finds_mark,[mira,scroll_7])]).
clause_template(c9, [pos(archivist,[mira])]).
clause_template(cn, [neg(trusted,[mira])]).  % negated goal

% fresh_clause — copy_term prevents variable aliasing between resolution steps
fresh_clause(Name, Fresh) :-
    clause_template(Name, Template),
    copy_term(Template, Fresh).

% Step 8: Resolution implementation and execution

% Two literals are complementary when one is pos and the other neg of same predicate/args
complementary(pos(P, Args), neg(P, Args)).
complementary(neg(P, Args), pos(P, Args)).

% resolve — binary resolution: pick complementary literals, return remaining disjuncts
resolve(C1, C2, Resolvent) :-
    select(L1, C1, Rest1),
    select(L2, C2, Rest2),
    complementary(L1, L2),
    append(Rest1, Rest2, Resolvent).

run_proof :-
    nl,
    writeln('Goal: trusted(mira)'),
    writeln('Negation added: ~trusted(mira)'),
    nl,

    fresh_clause(c3, C3), fresh_clause(c7, C7),
    resolve(C3, C7, Res1),
    format('Step 1 [C3 + C7]  resolve on inspects   --> ~w~n', [Res1]),

    fresh_clause(c8, C8),
    resolve(Res1, C8, Res2),
    format('Step 2 [R1 + C8]  resolve on finds_mark --> ~w~n', [Res2]), % should proves Mira verifies scroll_7

    fresh_clause(c1, C1), fresh_clause(c9, C9),
    resolve(C1, C9, Res3),
    format('Step 3 [C1 + C9]  resolve on archivist  --> ~w~n', [Res3]),

    resolve(Res3, Res2, Res4),
    format('Step 4 [R3 + R2]  resolve on verifies   --> ~w~n', [Res4]),

    fresh_clause(cn, CN),
    resolve(Res4, CN, Res5),
    format('Step 5 [R4 + CN]  resolve on trusted    --> ~w~n', [Res5]), % should prove Mira is trusted

    nl,
    ( Res5 = [] ->
        writeln('Empty clause [] derived. trusted(mira) is PROVED.')
    ;
        writeln('ERROR: empty clause not reached.')
    ).

:- initialization(run_proof, main).