#import "@preview/physica:0.9.8": innerproduct, super-T-as-transpose, dd, dv, pdv
#import "preamble.typ": linalg-notation
#set page(
  margin: 0.4cm,
  columns: 2,
)

#set text(size: 8.5pt)
#set list(marker: ([•], [‣], [◦]), indent: 0em, spacing: 0.5em)
#set math.mat(delim: "[")
#set math.equation(numbering: "(1)", supplement: [Eq.])
#show heading: set block(below: 0.4em, above: 0.4em)
#set block(below: 0.2em, above: 0.2em)
#set par(
  leading: 0.4em,  // Line spacing
  // spacing: 5.0em,
)
#set list(spacing: 0.55em)

#show heading.where(level: 1): set heading(numbering: "1")
#show heading.where(
  level: 1
): it => text(
  size: 9pt,
  it
)

#show heading.where(
  level: 2
): it => text(
  size: 8.5pt,
  it
)

#show heading.where(
  level: 3
): it => text(
  style: "italic",
  size: 8.5pt,
  it
)

#let vv = linalg-notation.with(bold: true, upright: false)
#let mm = linalg-notation.with(bold: true, upright: true)
#let wider = h(3em)

#let diag = math.op("diag")
#let tr = math.op("tr")
#let span = math.op("span")
#let dist = math.op("dist")
#let argmax = math.op("argmax")

#let Ber = math.op("Ber")  // Bernoulli distribution
#let Bin = math.op("Bin")  // Binomial distribution
#let Beta = math.op("Beta")  // Beta distribution

#show: super-T-as-transpose

#let inline-heading(body) = context {
  set block(
    // These should match those of `show heading`
    below: 0.4em,
    above: 0.4em,
  )
  show heading: box
  body
}

= Miscellaneous
- Sigmoid: $σ(x) = (1 + e^(-x))^(-1)$
- $hat(θ)_"MLE" = argmax_θ p(vv(y)|θ)$: Max of likelihood function
- $hat(θ)_"MAP" = argmax_θ p(θ|vv(y))$: Max of posterior distribution
- Plug-in estimate: Using either MAP or MLE as the parameter estimate instead of the full distribution
  - Better alternative: posterior predictive distribution using grid approximation.
- Uncertainty types:
  - Epistemic: Uncertainty about model parameters, can be reduced by more data
  - Aleatoric: Uncertainty inherent in the data, cannot be reduced by more data
  - Posterior captures epistemic uncertainty
  - Likelihood captures aleatoric uncertainty
  - Posterior predictive distribution captures both
== Metrics
- Mean squared error (MSE): $"MSE" = 1/N ∑_n (y_n - hat(y)_n)^2$
- Expected log predictive density (ELPD):
  - $"ELPD" = 1/N ∑^N_(n=1) ln p(y^*_n|vv(y), vv(x)^*)$
  - Like MSE but takes into account the uncertainty

= Fundamental Probability Theory
- Product rule: $p(vv(a), vv(b)) = p(vv(b)|vv(a)) p(vv(a))$
- Sum rule/Marginalisation: $p(vv(a)) = ∫ p(vv(a), vv(b)) dif vv(b)$
- Conditional: $p(vv(a)|vv(b)) = p(vv(a), vv(b)) \/p(vv(b))$
- Conditional independence: $p(vv(a), vv(b)|vv(c)) = p(vv(a)|vv(c)) p(vv(b)|vv(c))$
  - Does not generally hold
- Bayes Rule: $p(vv(a)|vv(b)) = p(vv(b)|vv(a)) p(vv(a)) \/p(vv(b))$
- Mean: $𝔼[vv(x)] = ∫ vv(x) p(vv(x)) dif vv(x)$
- Variance: $𝕍[vv(x)] = ∫ (vv(x) - 𝔼[vv(x)])^2 p(vv(x)) dif vv(x)$
- General expectation: $𝔼[f(vv(x))] = ∫ f(vv(x)) p(vv(x)) dif vv(x)$

= Bayesian Inference
- Prior,  $p(vv(θ))$: belief about parameter $vv(θ)$ before seeing data
  - Different types: uniform, informative, weakly informative, mathematically convenient, etc.
- Likelihood, $p(vv(y)|vv(θ))$: probability of data $vv(y)$ given parameter $vv(θ)$
- Posterior, $p(vv(θ)|vv(y))$: belief about parameter $vv(θ)$ after seeing data
- Evidence/marginal likelihood, $p(vv(y))$: probability of data $vv(y)$
- Joint distribution, $p(vv(θ), vv(y))$: probability of both parameter $vv(θ)$ and data $vv(y)$
- Posterior predictive distribution, $p(y^*|vv(y), vv(x), x^*)$: probability of new data $y^*$ given observed data $vv(y)$ and new input $x^*$

= Distributions
- Conjugate: A prior $p(vv(θ))$ is conjugate to a likelihood $p(vv(y)|vv(θ))$ if the posterior $p(vv(θ)|vv(y))$ is in the same family as the prior.
  - Example: Beta prior is conjugate to binomial likelihood:
    - Prior: $p(vv(θ)) = Beta(vv(θ)|a,b)$
    - Likelihood: $p(vv(y)|vv(θ)) = Bin(vv(y)|N, vv(θ))$
    - Posterior: $p(vv(θ)|vv(y)) = Beta(vv(θ)|a+y, b+N-y)$
    - Posterior mean: $𝔼[vv(θ)|vv(y)] = (a+y) / (a+b+N)$
  - (multivariate) Gaussian distribution is conjugate to itself
== Distributions Overview
- Gaussian: _Continuous distribution over $ℝ$_
  - $p(x|μ, σ^2) = 𝒩(x|μ, σ^2) = (1/sqrt(2 π σ^2)) e^(-(x-μ)^2/(2σ^2))$
  - $𝔼[x] = μ$, $𝕍[x] = σ^2$
- Multivariate Gaussian: _Continuous distribution over $ℝ^D$_
  - $p(vv(x)|vv(μ), mm(Σ)) = 𝒩(vv(x)|vv(μ), mm(Σ)) = (1/sqrt((2 π)^D det(mm(Σ)))) e^(-0.5 (vv(x)-vv(μ))^T mm(Σ)^(-1) (vv(x)-vv(μ)))$
  - $𝔼[vv(x)] = vv(μ)$, $𝕍[vv(x)] = mm(Σ)$
- Bernoulli: _Binary data_, $Ω={0, 1}$
  - $p(x|θ) = Ber(x|θ) = θ^x (1-θ)^(1-x)$
  - $𝔼[x] = θ$, $𝕍[x] = θ(1-θ)$
- Binomial: _$k$ out of $N$ successes_, $Ω={0, 1, ..., N}$
  - Arises as succeses from $N$ independent Bernoulli trials
    - $y=∑_i x_i$ where $x_i ∼ Ber(θ), quad i = 1, ..., N$
  - $p(y|N, θ) = Bin(y|N,θ) = binom(N, y) θ^y (1-θ)^(N-y)$
  - $𝔼[y] = N θ, quad 𝕍[y] = N θ (1-θ), quad hat(θ)_"MLE" = y/N$
- Beta: _Continuous distribution over $[0, 1]$_
  - $p(θ|a,b) = Beta(θ|a,b) = 1/B(a,b) θ^(a-1) (1-θ)^(b-1)$
    - $B(a,b) = (Γ(a) Γ(b)) / Γ(a+b), quad Γ(z) = ∫_0^∞ x^(z-1) e^(-x) dif x$
    - Uniform prior: $Beta(θ|1,1)$
  - $𝔼[θ] = a/(a+b), quad 𝕍[θ] = (a b) / ((a+b)^2 (a+b+1))$

= Techniques

== Grid Approximation
+ Define grid of parameter values $vv(θ)_i = {θ_(i, 1), θ_(1, 2), ..., θ_(i, M)}$
  - Grid is then $product_i vv(θ)_i$, the Cartesian product of the parameter discretisations
+ Evaluate posterior probability: $q(θ_k) = 1/Z p(vv(y),θ|vv(x)) = 1/Z tilde(π)_k = π_k$ where $k$ indexes the points
+ Compute normalisation constant: $Z = ∑_k tilde(π)_k$

== Evidence Approximation
- A method to estimate hyperparameters (prior variance, noise variance, etc.)
- Pick the hyperparameters that maximises the marginal likelihood (MLE Type II):
  - $α^*, β^* = argmax_(α, β) p(vv(y)|α, β) = argmax_(α, β) ln p(vv(y)|α, β)$
- Can be extended to MAP Type II by including a hyperprior:
  - $α^*, β^* = argmax_(α, β) p(α, β|vv(y)) = argmax_(α, β) ln p(vv(y)|α, β) + ln p(α, β)$
= Models

== Bayesian Linear Regression
- Model: $y = ϕ(vv(x^T)) vv(w) + vv(e)$, where $e_n ∼ 𝒩(0, σ^2)$
  - Assumptions: Gaussian prior.
  - $β≔1/σ^2$, _"noise precision"_
  - $ϕ(⋅)$ is basis function transformation, $vv(w)$ are regression weights
  - May introduce design matrix $mm(Φ)$ with rows $ϕ(vv(x_n^T))$ to write as $vv(y) = mm(Φ) vv(w) + vv(e)$
  - $hat(vv(w))_"MLE" = (mm(Φ)^T mm(Φ))^(-1) mm(Φ)^T vv(y)$
  - Prior: $p(vv(w)) = 𝒩(vv(w)|vv(m)_0, mm(S)_0)$
  - Posterior variance, $mm(S) = (mm(S)_0^(-1) + β mm(Φ)^T mm(Φ))^(-1)$
  - Posterior mean, $vv(m) = mm(S) (mm(S)_0^(-1) vv(m)_0 + β mm(Φ)^T vv(y))$
- Summary:
  - Prior: $p(vv(w)) = 𝒩(vv(w)|vv(m)_0, mm(S)_0)$
  - Likelihood: $p(vv(y)|vv(w)) = 𝒩(vv(y)|mm(Φ) vv(w), β^(-1) mm(I))$
  - Posterior: $p(vv(w)|vv(y)) = 𝒩(vv(w)|vv(m), mm(S))$
  - Evidence: $p(vv(y)|α, β) = 𝒩(vv(y)|mm(Φ) vv(m)_0, β^(-1) mm(I) + mm(Φ) α^(-1) mm(I) mm(Φ)^T)$
