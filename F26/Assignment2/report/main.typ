#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *
#import "@preview/cetz:0.4.2"
#import "@preview/algorithmic:0.1.0"
#import "@preview/physica:0.9.8": curl, grad, tensor, pdv, dv, TT
#import "@preview/unify:0.7.1": qty, num
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
    else if it.body == [Bibliography] {
      it
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
  [Assignment 2])
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

#let GP = math.cal("GP")


// = Introduction to Report <nonumber>

// Where the full calculatio

#counter(heading).update(0)
= Gaussian Processes and Covariance Functions <sec:1>

We are given the following covariance functions:
$
k_(1)(x, x') &= 2 exp(-(x - x')^2 / (2 dot 0.3^2))\
k_(2)(x, x') &= exp(-(x - x ')^2 / (2 dot 0.1^2))\
k_(3)(x, x') & = 4 + 2 x x'\
k_(4)(x, x') & = exp(- 2 sin(3 pi dot | x - x'|)^2)\
k_(5)(x, x') & = exp(- 2 sin(3 pi dot | x - x'|)^2) + 4 x x'\
k_(6)(x, x') & = 1/5 + min(x, x')
$ <eq:1-covar-funcs>

== <task:1.1>
We are to calculate the marginal prior mean and variance of
$
f_i (x) ∼ GP(0, k_i (x, x'))
$ <eq:1.1-func>
where $i ∈ {1, ..., 6}$.

We immediately note that $EE[f_i (x)] = 0$ by the construction in @eq:1.1-func.
We may calculate the variances by letting $x' = x$:
$
VV[f_i (x)] = k_i (x, x)
$

which yields:
$
VV[f_1 (x)] &= 2 exp(0) &&= 2\
VV[f_2 (x)] &= exp(0) &&= 1\
VV[f_3 (x)] &= 4 + 2 x x &&= 4 + 2x^2\
VV[f_4 (x)] &= exp(-2 sin(3π ⋅ 0)) &&= 1\
VV[f_5 (x)] &= exp(-2 sin(3π ⋅ 0)) + 4 x x &&= 1 + 4x^2\
VV[f_6 (x)] &= 1/5 + min(x, x) &&= 1/5 + x\
$ <eq:1.1-variances>

== <task:1.2>

We recall that a (weakly) _stationary_ covariance function is defined by invariance to translation, which is satisfied by ${k_1, k_2, k_4}$ as seen by the lack of $x$-dependence in @eq:1.1-variances.

== <task:1.3>

We map between the plots of @fig:1.3 and the covariance functions in @eq:1-covar-funcs:
- $k_1 = "(d)"$
  - Single Gaussian decay away from diagonal
  - Diagonal value of $2$
  - Slower decay than $k_2$
- $k_2 = "(a)"$
  - Single Gaussian decay away from diagonal
  - Diagonal value of $1$
  - Faster decay than $k_1$
- $k_3 = "(f)"$
  - Value of $4$ at $(x, x') = (0, 0)$
  - Diagonal goes as $2x^2 ⇒ k(1, 1) = 4 + 2 ⋅ 1^2 = 6$
  - No periodicity
  - $2 x x'$ gives hyperbolic level curves in $(x, x')$ plot
- $k_4 = "(e)"$
  - Diagonal value of $1$
  - Periodic in $x' - x$
- $k_5 = "(c)"$
  - Superimposition of $k_4$ and hyperbolic level curves as in $k_3$
- $k_6 = "(b)"$
  - $k_6 (0, 0) = 1/5$
  - $k_6 (2, 2) = 1/5 + 2$
  - Level sets are `|_`

#figure(
  image("manual/1_3.png"),
  caption: [_Figure 1_ from assignment description.]
) <fig:1.3>

== <task:1.4>

We are given
$
k_7 (x, x') = κ_0^2 + κ_1^2 x x' + κ_2^2 exp(- norm(x-x')_2^2 / (2ℓ^2))
$
where $κ_0, κ_1, κ_2 ≥ 0$ and $ℓ > 0$.

*NOTE FOR LECTURER: $κ_0$ not described in assignment. Since all are squared anyway, maybe just give $κ_0, κ_1, κ_2, ℓ ∈ ℝ$*

We plot this using an adaptation of the plotting routines used in the exercises for Lecture 6 to achieve @fig:1.4-1 and @fig:1.4-2 shown below.

We notice that the covariance function is weakly stationary for $κ_1 = 0$, as shown in @fig:1.4-1.

Further, the figures agree with our intuition around the terms in the covariance function:
- Constant term, $κ_0^2$: Size of vertical offset
- Linear term, $κ_1^2 x x'$: Slope of linear trend
- Squared exponential term, $κ_2^2 exp(- norm(x-x')_2^2 / (2ℓ^2))$: Local oscillations

#figure(
  image("output/1_4-1.png"),
  caption: [Covariance matrix and realisations associated with stationary covariance function],
) <fig:1.4-1>

#figure(
  image("output/1_4-2.png"),
  caption: [Covariance matrix and realisations associated with non-stationary covariance function],
) <fig:1.4-2>

= Laplace Approximation for Simple Neural Network <sec:2>

We are given a dataset $cal(D) = {(x_n, y_n)}_(n=1)^N$ where the elements $x_n, y_n$ come from:
$
vv(x) &= [&&9.589, &&7.375, &&4.647, &&2.501, &&2.538, &&6.783, &&4.294, &&5.111, &&0.130, &&0.783]\
vv(y) &= [&&3.032, &&3.349, &&2.906, &&2.126, &&1.538, &&2.787, &&3.078, &&2.993, &&0.828, -&&0.331]
$

We define a simple two-parameter neural network given by
$
f(x) = w_1 σ(x + w_0)
$ <eq:2-nn>

on which impose i.i.d Gaussian priors on the parameters $vv(w) = [w_0 space w_1] ∈ ℝ^2$ as given by
$
w_0 &∼ cal(N) (0, τ^2)\
w_1 &∼ cal(N) (0, τ^2)\
$

The activation function $σ : ℝ → (0, 1)$ is the logistic sigmoid function:
$
σ(x) = 1/(1 + exp(-x)).
$ <eq:2-sigmoid>

Lastly, we construct a probabilistic regression model:
$
p(y_n|x_n,vv(w)) = cal(N)(y_n|f(x), β^(-1)) = cal(N)(y_n|w_1 σ(x+w_0), β^(-1))
$ <eq:2-posterior-predictive>
where $β^(-1) > 0$ is the _noise variance_.

We let $τ=2, β=4$.

== <task:2.1>

We generate $S=100$ samples from the prior $p(vv(w))$ and pass these through the neural network given by @eq:2-nn for the a fine grid $x ∈ [0, 10]$. The resulting responses are plotted alongside the given dataset in @fig:2.1. Clearly, the prior does produce parameter estimates that describe the given dataset well.

#figure(
  image("output/2_1.png"),
  caption: [Responses associated with $S=100$ samples of the network parameters drawn from the prior $p(vv(w))$.]
) <fig:2.1>

== <task:2.2>

Section 3.3 of @murphy1 covers _linear_ Gaussian systems, which we know to be _conjugate_ with themselves. This gives the nice analytical results outlined in the book, but unfortunately do not apply here as we have introduced non-linearity through the activation function.

== <task:2.3>

We are given the joint probability
$
p(vv(y), vv(w)) = cal(N)(w_0|0, τ^2) cal(N)(w_1|0, τ^2) product_(n=1)^N cal(N)(y_n|w_1 σ(x_n + w_0), β^(-1)) 
$ <eq:2-joint>
which we log-transform to obtain
$
log p(vv(y), vv(w)) = log(cal(N)(w_0|0, τ^2)) + log(cal(N)(w_1|0, τ^2)) + sum_(n=1)^N log(cal(N)(y_n|w_1 σ(x_n + w_0), β^(-1))) 
$ <eq:2-log-joint>

Given $w_0=w_1=0$, we use the `jax.scipy.stats.norm.logpdf` function to construct a function matching @eq:2-log-joint, which yields
$
log p(vv(y), vv(w) = [0 space 0]|vv(x), β, τ) ≈ -130.95
$

== <task:2.4>

We start by recalling that for the sigmoid function given in @eq:2-sigmoid, we have identities:
$
dv(,x)σ(x) &= σ'(x) &&= σ(x)(1-σ(x))\
dv(,x,2)σ(x) &= σ''(x) &&= (1-2σ(x)) σ'(x)
$

We note that by chain rule:
$
dv(,x)σ(c + x) &= σ'(c + x) &&= σ(c + x)(1-σ(c + x))\
dv(,x,2)σ(c + x) &= σ''(c + x) &&= (1-2σ(c + x)) σ'(c + x)
$

Before tackling the gradient and Hessian of the logarithm of the joint density, we produce some intermediate results:
$
log p(vv(y), vv(w))
=&log[1/(sqrt(2π τ^2)) exp(- (w_0 - 0)^2 / (2τ^2))]
 +  log[1/(sqrt(2π τ^2)) exp(- (w_1 - 0)^2 / (2τ^2))]\
&+ sum_(n=1)^N log[1/(sqrt(2π β^(-1))) exp(- (y_n - w_1 σ(x_n + w_0))^2 / (2β^(-1)))]\

=&-(N+2) log(sqrt(2π)) - 2log(τ) - N log(sqrt(β^(-1))) - (w_0^2 + w_1^2)/(2τ^2)
- sum_(n=1)^N (y_n - w_1 σ(x_n + w_0))^2 / (2β^(-1))\
$

Thus the first 3 terms are constant w.r.t $vv(w)$ and disappear when calculating the gradient
$
∇_w log p(vv(y), vv(w)) = vec(
  pdv(log p(vv(y), vv(w)), w_0),
  pdv(log p(vv(y), vv(w)), w_1),
)
$

We calculate the partial derivative with respect to $w_0$ by constructing
$
log p(vv(y), vv(w)) = c - (w_0^2 + w_1^2)/(2τ^2) - sum_(n=1)^N f compose g(w_0, w_1)
$
where
$
f(g) &= 1/(2β^(-1)) g^2, &&wider f'(g) = β g\
g(w_0, w_1) &= y_n - w_1 σ(x_n + w_0), &&wider pdv(g, w_0) = -w_1 σ'(x_n + w_0)\
$
which by chain rule gives:
$
pdv(log p(vv(y), vv(w)), w_0) &= -w_0/τ^2 - sum_(n=1)^N dv(f, g) pdv(g, w_0)\
&= -w_0/τ^2 + β w_1 sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ'(x_n + w_0)
$

Similarly for the partial derivative w.r.t $w_1$:

$
log p(vv(y), vv(w)) = c - (w_0^2 + w_1^2)/(2τ^2) - sum_(n=1)^N f compose g (w_1)
$
where intermediate functions are as before, but we take partial derivative w.r.t $w_1$
$
pdv(g, w_1) = -σ(x_n + w_0)
$
which by chain rule gives:
$
pdv(log p(vv(y), vv(w)), w_1) &= -w_1/τ^2 - sum_(n=1)^N dv(f, g) dv(g, w_1)\
&= -w_1/τ^2 + β sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ(x_n + w_0)\
$

Thus we have the gradient:
$
∇_w log p(vv(y), vv(w)) = vec(
  -w_0/τ^2 + β w_1 sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ'(x_n + w_0),
  -w_1/τ^2 + β sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ(x_n + w_0),
)
$ <eq:2-log-gradient>

We may seek to compute the Hessian:
$
∇^2_w log p(vv(y), vv(w)) = mat(
  H_00, H_01; H_10, H_11
)
$

where $H_(i j) = pdv(log p(vv(y), vv(w)), w_i, w_j)$ and $H_01 = H_10$.

We consider $H_00$:
$
H_00 &= pdv(log p(vv(y), vv(w)), w_0, 2) = pdv(, w_0) [-w_0/τ^2 + β w_1 sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ'(x_n + w_0)]\
&= -1/τ^2 + β w_1 sum_(n=1)^N [-w_1 (σ'(x_n + w_0))^2 + (y_n - w_1 σ(x_n + w_0)) σ''(x_n + w_0)].
$

Next, we consider $H_11$:
$
H_11 &= pdv(log p(vv(y), vv(w)), w_1, 2) = pdv(, w_1) [-w_1/τ^2 + β sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ(x_n + w_0)]\
&= -1/τ^2 - β sum_(n=1)^N σ^2(x_n + w_0).
$

Lastly, we consider the mixed terms:
$
H_01 = H_10 &= pdv(log p(vv(y), vv(w)), w_0, w_1) = pdv(, w_1) [-w_0/τ^2 + β w_1 sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ'(x_n + w_0)]\
&= β [sum_(n=1)^N (y_n - w_1 σ(x_n + w_0)) σ'(x_n + w_0) - w_1 sum_(n=1)^N σ(x_n + w_0) σ'(x_n + w_0)]\
&= β sum_(n=1)^N [y_n - 2 w_1 σ(x_n + w_0)] σ'(x_n + w_0)
$

Which concludes the analytical derivation of the elements of the Hessian. 

== <task:2.5>

We propose to approximate the posterior distribution $p(vv(w)|vv(y))$ by using the Laplace approximation, $q(vv(w))$, in which we replace the full distribution by a normal distribution with the location and variance determined by MAP estimate of the posterior distribution mode and the Hessian evaluated at that mode.

From Lecture 4, we recall:
$
q(vv(w)) = cal(N)(vv(w)|vv(w)_"MAP", -H^(-1)(vv(w)_"MAP"))
$

where $H^(-1) (vv(w)_"MAP")$ denotes the inverse of the Hessian matrix evaluated at the MAP estimate.

We may obtain the point $vv(w)_"MAP"$ by minimising the negative log of the posterior, $p(vv(w)|vv(y))$:
$
vv(w)_"MAP"
&= arg min_vv(w) [-log p(vv(w)|vv(y))]\
&= arg min_vv(w) [-log [p(vv(y), vv(w))/p(vv(y))]]\
&= arg min_vv(w) [-log p(vv(y), vv(w)) + log p(vv(y))]\
&= arg min_vv(w) [-log p(vv(y), vv(w))].\
$

This is trivial to obtain using the expression in @eq:2-log-joint and standard optimisation routines such as `scipy.optimization.minimize`, which can additionally be fed the negative of the gradient given by @eq:2-log-gradient as the Jacobian to the objective.

After obtaining $vv(w)_"MAP"$, we have fully determined the Laplace approximation. By carried out the numerical optimisation, we find:
$
vv(w)_"MAP" = (-2.204, 3.104)
$

We additionally compute the covariance matrix associated with the Laplace approximation:
$
-H^(-1)(vv(w)_"MAP") = mat(
  0.1677, -0.046;
  -0.046, 0.0524;
)

$

== <task:2.6>

We can produce a 2D filled contour map using the _grid approximation_ by simply constructing a relatively dense grid of the parameters, $(w_0, w_1)$, and evaluating the joint density on all points in this grid. By the same mechanism used in @task:2.5, the level curves of the joint density will be identical to the curves of the posterior probability up to a constant scaling factor.

Atop the filled contour plot, we produce another contour plot with just 7 level curves using the Laplace approximation, $p(vv(w)|vv(y)) ≈ q(vv(w))$ using the MAP estimate, $vv(w)_"MAP"$, obtained in @task:2.5, in order to produce @fig:2.6.


#figure(
  image("output/2_6.png"),
  caption: [Posterior distributions obtained using grid and Laplace approximations using $1000^2$ linearly spaced points in the parameter space.]
) <fig:2.6>

We note in @fig:2.6 that the Laplace and grid approximations are in good agreement, indicating that the posterior distribution is well-modelled by a 2D Gaussian approximation.

== <task:2.7>

Having validated that the Laplace approximation is sensible in @task:2.6, we draw $S=100$ realisations from the approximate posterior distribution and compute the response of the neural network using @eq:2-nn. These responses are plotted in @fig:2.7 alongside (low count) empirical estimates of the mean and 95% confidence interval over the input interval $x∈ [0, 10]$ beneath the data given in the assignment description.

It is immediately noticeable how the incorporation of the observations produce a posterior distribution over the parameters $vv(w)$ which aligns much better with the data. Note that the 95% interval only considers the uncertainty from the priors and not the data noise, $β$.

#figure(
  image("output/2_7.png"),
  caption: [
    $S=100$ samples drawn from the Laplace approximated posterior distribution.
    Mean and confidence intervals are estimated empirically from the 100 samples.
  ]
) <fig:2.7>

== <task:2.8>

Similarly, we draw another $S=num("100 000")$ samples from the approximate posterior distribution at $x=8$ and compute the probability of the event $f(8) > 3$ by:
$
p(f(x=8) > 3) ≈ N_"cond" / S = 66.1%
$

where $N_"cond"$ is the number of realisations for which the condition $f(8) > 3$ is true.


== <task:2.9>

We now seek to determine statistics about the approximate predictive posterior distribution, $p(y^*|vv(y), x^*)$, which is given by @eq:2-posterior-predictive:
$
p(y_n|x_n,vv(w)) = cal(N)(y_n|f(x), β^(-1)) = cal(N)(y_n|w_1 σ(x+w_0), β^(-1))
$ <eq:2-posterior-predictive-2>

We thus draw another $S = num("100 000")$ samples from the posterior distribution at $x^*=3.75$, which we use to compute a vector of predictive means $vv(f)(x^*)$. By @eq:2-posterior-predictive-2 we simply need to add normally distributed noise with a variance of $β^(-1) = 1/4$ in order to produce the vector $vv(y)^*$ containing the $S= num("100 000")$ predictions.

From these predictions, we may compute empirical, Monte Carlo estimates of the mean and 95% confidence intervals using
$
μ &= (sum vv(y)^*) /S ≈ 2.53\
[P_(2.5%), P_(97.5%)]
&= [P_(2.5%)(vv(y)^*), P_(97.5%)(vv(y)^*)] ≈ [1.471, 3.579]
$
where $P_k (vv(y)^*)$ may be calculated using the percentile function in `jax.numpy.percentile`.

This ensures we also take into consideration the _aleatoric_ uncertainty given by $β=4$. in addition to the _epistemic_ uncertainty arising from the uncertainty in the prior, $τ=2$.

#bibliography("references.bib")