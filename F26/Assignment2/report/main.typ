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

#set heading(numbering: "1.1", supplement: "Part")
#show heading: it => {
  block(
    if it.has("label") and it.label == <nonumber> {
      it.body
    }
    else if it.level == 1 {
      "Part " + counter(heading).display() + ": " + it.body
    } else if it.level == 2 {
      "Task " + counter(heading).display() + ": " + it.body
    } else if it.level == 3 {
      it.body
    }
  )
}

#show ref: it => {
  let el = it.element
  if str(it.target).starts-with("task:") {
    link(it.target, "Task " + numbering(el.numbering, ..counter(heading).at(it.target)))
  } else {
    it
  }
}

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
#let Poisson = math.op("Poisson")
#let GammaD = math.op("Gamma")

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
- Tymoteusz Barcinski <`s221937@dtu.dk`>


// = Introduction to Report <nonumber>

// Where the full calculatio

#counter(heading).update(0)
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
EE[θ] = a_0/(a_0+b_0)
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

The _central_ credible interval $[l, u]$ corresponding to $1-α=95%$ may be found using the inverse of the cumulative distribution function, $F$ according to @murphy1[4.6.6]. Note that there are infinitely many ways of picking an interval containing the probability mass $1-α$ @murphy1[4.6.6], we chose to use central credible interval.
$
l = F^(-1) (α\/2) = 0.025, wider u = F^(-1) (1-α\/2) = 0.975
$

Which have been found using `scipy.stats.beta.interval(0.95, 1, 1)` reveals the following, simple credible interval:
$
P(θ ∈ [0.025, 0.975]) = 1 - alpha = 95%
$

== <task:1.2>

We refer to @eq:beta-binom-post and find the posterior to be given by
$
  p(θ|y) = Beta(θ|a_0+y, b_0 + N - y) = Beta(θ|1+4, 1+115-4) = Beta(θ|5, 112)
$

from which we obtain mean and credibility intervals
$
EE[θ_"post"] &= 5/(5 + 112) = 0.0427\
P(θ ∈ [0.0141, 0.0859]|y) &= 1 - alpha = 95%
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

This gives the distribution shown in @fig:1_3_ppd.

#figure(
  image("output/1_3_ppd.png"),
  caption: [
    The probability masses of the posterior predictive distribution $p(y^*=k|y)$.
  ]
) <fig:1_3_ppd>

== <task:1.4>

We seek to find the probability that at least one of the next $N^*=20$ customers makes a purchase, that is we seek
$
p(y^*≥1|y) = 1-p(y^*=0|y) = 1 - 0.4456 = 0.5544 ≈ 55%
$

That is, there is a 55% chance that at least one of the 20 next potential customers will make a purchase.

== <task:1.5>

As also shown in @fig:1_3_ppd, we find the mean of the posterior predictive distribution to be
$
EE_(p(y^*|y)) [y^*] = sum_(k=0)^(N^*) k ⋅ p(y^*=k|y) ≈ 0.8547
$

and variance to be
$
VV_(p(y^*|y)) [y^*] = EE_(p(y^*|y))[(y^* - EE_(p(y^*|y)) [y^*])^2] = sum_(k=0)^(N^*) (k - EE_(p(y^*|y)) [y^*])^2  p(y^*=k|y) ≈ 0.9499.
$

= Linear Gaussian Systems <sec:2>
#let z1 = $vv(z)_1$
#let z2 = $vv(z)_2$

We are given the following Gaussian Linear System:
$
z1 &∼ cal(N)(vv(0), v mm(I))\
z2|z1 &∼ cal(N)(z1, v mm(I))\
y|z2 &∼ cal(N)(vv(a)^TT z2, σ^2)
$

where $z1, z2, vv(a) ∈ ℝ^2, y ∈ ℝ$

The joint is then given by
$
p(y, z1, z2) = p(y|z2) p(z2|z1) p(z1)
$

=== Linear Gaussian System Results from @murphy1

In the notation of @murphy1, we state the results of @murphy1[3.3] without proof.
Given $vv(z)∈ℝ^L, vv(y)∈ℝ^D$ described by the following joint distribution:
$
p(vv(z)) &= cal(N)(vv(z)|vv(μ)_z, mm(Σ)_z)\
p(vv(y)|vv(z)) &= cal(N)(vv(y)| mm(W) vv(z) + vv(b), mm(Σ)_y)\
$

The posterior is then given by "Bayes rule for Gaussians" @murphy1[3.3.1]:
$
p(vv(z)|vv(y)) &= cal(N)(vv(z)|vv(μ)_(z|y), mm(Σ)_(z|y))\
mm(Σ)^(-1)_(z|y) &= mm(Σ)^(-1)_z + mm(W)^TT mm(Σ)^(-1)_y mm(W)\
vv(μ)_(z|y) &= mm(Σ)_(z|y) [mm(W)^TT mm(Σ)_y^(-1)(vv(y)-vv(b)) + mm(Σ)^(-1)_z vv(μ)_z]
$ <eq:gaussian-bayes>

with the resulting posterior normalization (evidence):
$
p(vv(y)) = cal(N)(vv(y)|mm(W) vv(μ)_z + vv(b), mm(Σ)_y + mm(W) mm(Σ)_z mm(W)^TT)
$

These properties arise because the Gaussian prior is conjugate to the Gaussian likelihood, with the resulting posterior also being Gaussian. As such, we consider Linear Gaussian systems _closed_ under Bayesian conditioning @murphy1[3.3].

Similarly, we may consider the joint distribution $p(vv(z), vv(y)) = p(vv(z)) p(vv(y)|vv(z))$, which follows:
$
p(vv(z), vv(y)) = cal(N)( vec(vv(z), vv(y)) mid(|)
vec(vv(μ)_z, mm(W) vv(μ)_z + vv(b)),
mat(
  delim: "(",
  mm(Σ)_z, mm(Σ)_z mm(W)^TT;
  mm(W) mm(Σ)_z, mm(Σ)_y + mm(W) mm(Σ)_z mm(W)^TT
)
)
$ <eq:gaussian-joint>

== Determine $p(y)$ <task:2.1>

Using the results from above, it is readily apparent that we must first determine the distribution $p(z2)$ in order to find $p(y)$. By mapping the expressions in the assignment description against the notation of the results from @murphy1, we find
$
p(z2) &= cal(N)(z2| mm(I) vv(0) + vv(0), v mm(I) + mm(I) v mm(I) mm(I)^TT) = cal(N)(z2|vv(0), 2 v mm(I))\
p(y) &= cal(N)(y|vv(a)^TT vv(0) + vv(0), σ^2 + vv(a)^TT 2 v mm(I) vv(a)) = cal(N)(y|vv(0), σ^2 + 2v vv(a)^TT vv(a))
$

== Determine $p(y, z2|z1)$ <task:2.2>

We may begin by using the product rule
$
p(y, z2|z1) = p(y|z2, z1) p(z2|z1) = p(y|z2) p(z2|z1)
$

Where the second equality highlights the fact that conditioning on $z2$ also implicitly implies conditioning on $z1$.

Since we are conditioning on $z1$, we may leverage @eq:gaussian-joint and the distributions given the assignment description to find
$
p(y, z2|z1) = p(y|z2) p(z2|z1) 
&= 
cal(N) (vec(z2, y) mid(|)
vec(z1, vv(a)^TT z1),
mat(
  delim: "(",
  v mm(I), v mm(I) vv(a);
  vv(a)^TT v mm(I), σ^2 + vv(a)^TT v mm(I) vv(a)
)
)\
&=
cal(N) (vec(z2, y) mid(|)
vec(z1, vv(a)^TT z1),
mat(
  delim: "(",
  v mm(I), v vv(a);
  v vv(a)^TT , σ^2 + v vv(a)^TT vv(a)
)
)
$

== Determine $p(y|z1)$ <task:2.3>

Using the result from @task:2.2, we may marginalise out $z2$ simply by picking out the blocks corresponding to $y$ — that is, ignoring the mean, variance and covariance of $z2$. In this case we are left with
$
p(y|z1) = cal(N)(y|vv(a)^TT z1, σ^2 + v vv(a)^TT vv(a)).
$

== Determine $p(z1|y)$ <task:2.4>

Using Bayes rule for Gaussians as described in @eq:gaussian-bayes, the posterior found in @task:2.3, and the marginal distribution we found in @task:2.1, we find:
$
p(z1|y) = cal(N)(z1|vv(μ)_(z1|y), mm(Σ)_(z1|y))
$
where
$
mm(Σ)^(-1)_(z1|y) &= (v mm(I))^(-1) + vv(a) (σ^2 + v vv(a)^TT vv(a) )^(-1) vv(a)^TT\
mm(Σ)_(z1|y) &= (1/v mm(I) + 1/(σ^2 + v vv(a)^TT vv(a) ) vv(a) vv(a)^TT)^(-1)\
vv(μ)_(z1|y)
&= mm(Σ)_(z1|y) [ vv(a) (σ^2 + v vv(a)^TT vv(a))^(-1) y + (v mm(I))^(-1) vv(0)]\
&= mm(Σ)_(z1|y) vv(a) (σ^2 + v vv(a)^TT vv(a))^(-1) y\
$

= A Conjugate Model for Count Data <sec:3>

We are given the probability mass/density functions of the Poisson and Gamma distributions:
$
p(y_i|λ) &= Poisson(λ) &&= (λ^(y_i) e^(-λ))/(y_i !)\
p(λ|a_0, b_0) &= GammaD(a_0, b_0) &&= (b_0^(a_0))/Γ(a_0) λ^(a_0-1) e^(-b_0 λ)
$

where $λ>0, a_0>0$, and $vv(y) = {y_i}_(i=0)^N$ are assumed to be conditionally independent given $λ$.

== Determine $p(vv(y), λ)$ <task:3.1>
From the product rule:
$
p(vv(y), λ)
&= p(vv(y)|λ) p(λ)\
&= [∏_(i=1)^N p(y_i|λ) ] p(λ)\
&= [∏_(i=1)^N (λ^(y_i) e^(-λ))/(y_i !)](b_0^(a_0))/Γ(a_0) λ^(a_0-1) e^(-b_0 λ)\
&= (λ^(∑ y_i) e^(-N λ))/(∏_(i=1)^N y_i !)(b_0^(a_0))/Γ(a_0) λ^(a_0-1) e^(-b_0 λ)\
&= (λ^(∑ y_i + a_0 - 1) e^(-(N+b_0)λ))/(∏_(i=1)^N y_i !) (b_0^(a_0))/(Γ(a_0))
$

== Show $log p(λ|a,b) = (a - 1) log(λ) - b λ + "const" $<task:3.2>

$
log p(λ|a,b)
&= log[b^a / Γ(a) λ^(a-1) e^(-b λ)]\
&= underbrace(a log(b) - log(Γ(a)), "constant w.r.t" λ) + (a-1) log(λ) -b λ\
&= (a-1) log(λ) -b λ + "const"\
$

== Derive $p(λ|vv(y))$ <task:3.3>
We consider Bayes rule
$
p(λ|vv(y)) = (p(vv(y)|λ) p(λ))/p(vv(y)) = p(vv(y), λ)/p(vv(y))
$
which we log-transform to use the result of @task:3.2
$
log p(λ|vv(y))
&= underbrace(log p(vv(y), λ), #[@task:3.1]) - underbrace(log p(vv(y)), "const. w.r.t" λ)\
&= log((λ^(∑ y_i + a_0 - 1) e^(-(N+b_0)λ))/(∏_(i=1)^N y_i !) (b_0^(a_0))/(Γ(a_0))) - c_1\
&= (a_0 - 1 + ∑_(i=1)^N y_i) log(λ) - (b_0 + N) λ - underbrace(log(y_i !) + a_0 log(b_0) - log(Γ(a_0)), "const. w.r.t" λ) - c_1 \
&= (a_0-1 + ∑_(i=1)^N y_i ) log(λ) - (b_0+N) λ + c_2\
&= log GammaD(λ mid(|) a_0+∑_(i=1)^N y_i, b_0 + N) wider wider #[By comp. against @task:3.2]
$

Thus, we conclude that $p(λ|vv(y))$ is given by a Gamma distribution $GammaD(a_N, b_N)$ where  parameters are determined using
$
a_N &= a_0 + sum_(i=1)^N y_i\
b_N &= b_0 + N\
$

== <task:3.4>

Given
$
vv(y) &= (7, 4, 8, 11, 12)\
N &= 5\
a_0 &= 1\
b_0 &= 1/10 \
$

We find using the result of @task:3.3:
$
a_N &= 1 + 42 = 43\
b_N &= 1/10 + 5 = 5.1\
$
Therefore the posterior distribution of $lambda$ is the following
$
lambda | bold(y) ~ GammaD(a = 43, b = 5.1), quad E[lambda | bold(y)] = 43 / (5.1) = 8.431
$

== <task:3.5>
The plot @fig:3_5_ppd presents the prior and posterior distribution of $lambda$.

#figure(
  image("output/3_5_ppd.png"),
  caption: [
    Prior and posterior distribution of $lambda$.
  ]
) <fig:3_5_ppd>


#bibliography("references.bib")
