#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "@preview/cetz:0.4.2"
#import "@preview/unify:0.7.1"
#import "@preview/algorithmic:0.1.0"
#import "@preview/physica:0.9.8": curl, grad, tensor, pdv, dv, TT
// #import algorithmic: algorithm

#import "preamble.typ": mref, mathformatter

#show: codly-init.with()

#codly(languages: codly-languages)

#set math.equation(numbering: "(1)")

#set heading(numbering: "1.1: ", supplement: "Part")
#show heading: it => {
  let supp = none
  if it.level == 1 {
    "Part " + counter(heading).display() + it.body
  } else if it.level == 2 {
    "Task " + counter(heading).display() + it.body
  } else if it.level == 3 {
    it.body
  }
  
}
  
#show <nonumber>: set heading(numbering: none)

#set page(
  numbering: "1/1",
  margin: (
    top: 1.5cm,
    bottom: 1.5cm,
    left: 1.5cm,
    right: 2.5cm,
  )
)

#set text(
  size: 11pt
)

#let appendix(body) = {
  set heading(numbering: "A.1", supplement: [Appendix])
  counter(heading).update(0)
  body
}

#let vv = mathformatter(underbars: 0, bold: true, upright: false)
#let mm = mathformatter(underbars: 0, bold: false, upright: true)
#set math.mat(delim:"[")

#let wider = h(3em)

#let Binomial = math.op("Binomial")
#let Bin = math.op("Bin")
#let Beta = math.op("Beta")
#let EE = math.op(math.bb("E"))

#align(center,
  [#text(
  18pt,
  weight: "bold",
  [Assignment 1])
  #v(-6pt)
  #text(
    14pt,
    [02477 — Bayesian Machine Learning
  ]
  )
])

#v(8pt)
- Jeppe Klitgaard <`s250250@dtu.dk`>
- Tymoteusz Barcinski <`s221937@dtu.dk`> #h(3em) _(not taking exam)_

= The Beta-Binomial Model <sec:1>

We are to investigate the sales on a website using the Beta-Binomial conjugate model as defined by the prior, $p(θ)$ and likelihood $p(y|θ)$ parameterised as:
$
θ &∼ Beta(a_0, b_0) &&= 1/B(a_0, b_0) θ^(a_0-1) (1-θ)^(b_0-1),\
y|θ &∼ Binomial(y|N, θ) &&= binom(N, y) θ^y (1-θ)^(N-y),
$ <eq:dists>

where the prior parameters $a_0 = b_0 = 1$ and $N=115$ denotes the number of potential customers, of which $y=4$ have made a purchase, while the beta function is given by:
$
B(a_0, b_0) = ∫ θ^(a_0-1) (1-θ)^(b_0-1) dif θ = (Γ(a_0) Γ(b_0))/(Γ(a_0+b_0))
$ <eq:beta-func>

We are tasked with considering the posterior prediction given $N^* = 20$.

We recall without the following properties of the beta and binomial distributions as well as the beta-binomial conjugate model:

=== Beta Distribution
$
EE[θ] = a/(a+b)
$ <eq:beta-mean>

=== Beta-Binomial Model

Given prior $p(θ) = Beta(a_0, b_0)$ and likelihood $p(y|θ) = Bin(N, θ)$ the posterior is given by:
$
  p(θ|y) = Beta(θ|a_0+y, b_0 + N - y)
$ <eq:beta-binom-post>

== <task:1.1>

We know that the prior is distributed according to the the Beta distribution $p(θ|a_0, b_0)$, which by @eq:beta-mean gives:
$
EE[θ] = a_0/(a_0+b_0) = 1/(1+1) = 1/2 
$

The _central_ credible interval $[l, u]$ corresponding to $1-α=95%$ may be found using the inverse of the cumulative distribution function, $F$ according to @murphy1[4.6.6]:
$
l = F^(-1) (α\/2), wider u = F^(-1) (1-α\/2)
$

Evaluating using `scipy.stats.beta.interval(0.95, 1, 1)` reveals the following, simple credible interval:
$
[l, u]_(95%) = [0.025, 0.975]
$

== <task:1.2>

We refer to @eq:beta-binom-post and find the posterior to be given by
$
  p(θ|y) = Beta(θ|a_0+y, b_0 + N - y) = Beta(θ|1+4, 1+115-4) = Beta(θ|5, 112)
$

from which we obtain mean and credibility intervals
$
EE[θ_"post"] &= 5/(5 + 112) = 0.0427\
[l, u]_(95%,"post") &= [0.0141, 0.0859]
$

== <task:1.3>

We seek the _posterior predictive distribution_, $p(y^*|y)$, which may be found through the joint distribution as follows:
$
  p(y^*|y)
  &= ∫ p(y^*, θ|y) dif θ &&wider "Marginalisation"\
  &= ∫ p(y^*, y, θ)/ p(y) dif θ &&wider "Conditional"\
  &= ∫ (p(y^*, y|θ) p(θ)) / p(y) dif θ &&wider "Product rule"\
  &= ∫ (p(y^*|θ) p(y|θ) p(θ)) / p(y) dif θ &&wider "Conditional Independence"\
  &= ∫ p(y^*|θ) p(θ|y) dif θ &&wider "Bayes"\
$

Note that it is assumed that $y$ and $y^*$ are _independent and identically distributed_.

Following the treatment in Lecture 2, Slides 12-14, we may arrive at a closed-form expression for the resulting distribution over the probability that a given number of purchases $k$ are made:
$
p(y^*=k|y)
&= ∫ p(y^*=k|θ) p(θ|y) dif θ\
&= ∫ Bin(y^*=k|N^*, θ) Beta(θ|a_0+y, b_0 + N - y) dif θ\
&= ∫ binom(N^*, k) θ^k (1-θ)^(N^*-k) 1/B(a_0 + y, b_0 + N - y) θ^(a_0+y-1) (1-θ)^(b_0 + N - y -1) dif θ\
&= binom(N^*, k) 1/B(a_0 + y, b_0 + N - y) ∫ θ^k (1-θ)^(N^*-k) θ^(a_0+y-1) (1-θ)^(b_0 + N - y -1) dif θ\
&= binom(N^*, k) 1/B(a_0 + y, b_0 + N - y) ∫ θ^(k+a_0+y-1) (1-θ)^(N^*-k+b_0+N-y-1) dif θ\
&= binom(N^*, k) B(k+a_0+y, N^*-k+b_0+N-y)/B(a_0 + y, b_0 + N - y)\
&= binom(N^*, k) B(k+a_0+y, N^*-k+b_0+N-y)/B(a_0 + y, b_0 + N - y)
$

TODO

= Linear Gaussian Systems <sec:2>

= A Conjugate Model for Count Data <sec:3>

= Appendix

#bibliography("references.bib")
