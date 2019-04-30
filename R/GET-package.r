#' GET: Global Envelopes in R
#'
#' Global envelopes alias central regions and global envelope tests, including
#' global envelope (tests) for single and many functions and multivariate vectors,
#' adjusted global envelope tests, graphical functional ANOVA and general linear model (GLM).
#'
#'
#' The \pkg{GET} library provides central regions (i.e. global envelopes) and global envelope tests.
#' The central regions can be constructed from (functional) data.
#' The tests are Monte Carlo tests, which demand simulations from the tested null model.
#' The methods are applicable for any multivariate vector data and functional data (after discretization).
#'
#' In the special case of point processes, the functions are typically estimators of summary functions.
#' The package supports the use of the R library \pkg{spatstat} for generating
#' simulations and calculating estimators of the chosen summary function, but alternatively these
#' can be done by any other way, thus allowing for any models/functions.
#'
#'
#' @section Key functions in \pkg{GET}:
#' \itemize{
#' \item \emph{Central regions} or \emph{global envelopes} or \emph{confidence bands}:
#' \code{\link{central_region}}.
#' E.g. 50\% central region of growth curves of girls \code{\link[fda]{growth}}.
#' \itemize{
#'            \item First create a curve_set of the growth curves, e.g.
#'
#'                  \code{
#'                    cset <- create_curve_set(list(r = as.numeric(row.names(growth$hgtf)),
#'                                                  obs = growth$hgtf))
#'                  }
#'            \item Then calculate 50\% central region (see \code{\link{central_region}} for further arguments)
#'
#'                  \code{
#'                    cr <- central_region(cset, coverage = 0.5)
#'                  }
#'            \item Plot the result (see \code{\link{plot.global_envelope}} for plotting options)
#'
#'                  \code{
#'                    plot(cr)
#'                  }
#' }
#' It is also possible to do combined central regions for several sets of curves provided in a list
#' for the function, see examples in \code{\link{central_region}}.
#'
#' \item \emph{Global envelope tests}: \code{\link{global_envelope_test}} is the main function.
#' E.g. A test of complete spatial randomness (CSR) for a point pattern \code{X}:
#'
#' \code{X <- spruces # an example pattern from spatstat}
#'
#' \itemize{
#'            \item Use \code{\link[spatstat]{envelope}} to create nsim simulations
#'                  under CSR and to calculate the functions you want (below K-functions by Kest).
#'                  Important: use the option 'savefuns=TRUE' and
#'                  specify the number of simulations \code{nsim}.
#'
#'                  \code{
#'                    env <- envelope(X, nsim=999, savefuns=TRUE, fun=Kest,
#'                                    simulate=expression(runifpoint(X$n, win=X$window)))
#'                  }
#'            \item Perform the test (see \code{\link{global_envelope_test}} for further arguments)
#'
#'                  \code{
#'                    res <- global_envelope_test(env)
#'                  }
#'            \item Plot the result (see \code{\link{plot.global_envelope}} for plotting options)
#'
#'                  \code{
#'                    plot(res)
#'                  }
#' }
#' It is also possible to do combined global envelope tests for several sets of curves provided in a list
#' for the function, see examples in \code{\link{global_envelope_test}}.
#' }
#'
#' \itemize{
#'  \item \emph{Functional ordering}: \code{\link{central_region}} and \code{\link{global_envelope_test}}
#'  are based on different measures for ordering the functions (or vectors) from
#'  the most extreme to the least extreme ones. The core functionality of calculating the measures
#'  is in the function \code{\link{forder}}, which can be used to obtain different measures for sets of
#'  curves. Usually there is no need to call \code{\link{forder}} directly.
#' \item \emph{Functional boxplots}: \code{\link{fboxplot}}
#' \item \emph{Adjusted} global envelope tests for composite hypotheses
#' \itemize{
#'   \item \code{\link{dg.global_envelope_test}}, see a detailed example in \code{\link{saplings}}
#' }
#' Also the adjusted tests can be based on several test functions.
#' \item \emph{One-way functional ANOVA}:
#'  \itemize{
#'   \item \emph{Graphical} functional ANOVA tests: \code{\link{graph.fanova}}
#'   \item \emph{Graphical} functional ANOVA tests for images (2d functions): \code{\link{graph.fanova2d}}
#'   \item Global rank envelope based on F-values: \code{\link{frank.fanova}}
#'   \item Global rank envelope based on F-values for images: \code{\link{frank.fanova2d}}
#'  }
#' \item \emph{Functional general linear model (GLM)}:
#'  \itemize{
#'   \item \emph{Graphical} functional GLM: \code{\link{graph.fglm}}
#'   \item \emph{Graphical} functional GLM for images: \code{\link{graph.fglm2d}}
#'   \item Global rank envelope based on F-values: \code{\link{frank.fglm}}
#'   \item Global rank envelope based on F-values: \code{\link{frank.fglm2d}}
#'  }
#' \item Wrapper functions to perform global envelopes for specific purposes:
#'  \itemize{
#'   \item Graphical n sample test of correspondence of distribution functions: \code{\link{GET.necdf}}
#'   \item Variogram and residual variogram with global envelopes: \code{\link{GET.variogram}}
#'  }
#'
#' \item Deviation tests (for simple hypothesis): \code{\link{deviation_test}} (no gpaphical
#' interpretation)
#' }
#' See the help files of the functions for examples.
#'
#' @section Workflow for (single hypothesis) tests based on single functions:
#'
#' To perform a test you always first need to obtain the test function T(r)
#' for your data (T_1(r)) and for each simulation (T_2(r), ..., T_{nsim+1}(r)) in one way or another.
#' Given the set of the functions T_i(r), i=1,...,nsim+1, you can perform a test
#' by \code{\link{global_envelope_test}}.
#'
#' 1) The workflow when using your own programs for simulations:
#'
#' \itemize{
#' \item (Fit the model and) Create nsim simulations from the (fitted) null model.
#' \item Calculate the functions T_1(r), T_2(r), ..., T_{nsim+1}(r).
#' \item Use \code{\link{create_curve_set}} to create a curve_set object
#'       from the functions T_i(r), i=1,...,s+1.
#' \item Perform the test and plot the result
#'
#'       \code{res <- global_envelope_test(curve_set) # curve_set is the 'curve_set'-object you created}
#'
#'       \code{plot(res)}
#' }
#'
#' 2) The workflow utilizing \pkg{spatstat}:
#'
#' E.g. Say we have a point pattern, for which we would like to test a hypothesis, as a \code{\link[spatstat]{ppp}} object.
#'
#' \code{X <- spruces # an example pattern from spatstat}
#'
#' \itemize{
#'    \item Test complete spatial randomness (CSR):
#'          \itemize{
#'            \item Use \code{\link[spatstat]{envelope}} to create nsim simulations
#'                  under CSR and to calculate the functions you want.
#'                  Important: use the option 'savefuns=TRUE' and
#'                  specify the number of simulations \code{nsim}.
#'                  See the help documentation in \pkg{spatstat}
#'                  for possible test functions (if \code{fun} not given, \code{Kest} is used,
#'                  i.e. an estimator of the K function).
#'
#'                  Making 999 simulations of CSR
#'                  and estimating K-function for each of them and data
#'                  (the argument \code{simulate} specifies for \code{envelope} how to perform
#'                  simulations under CSR):
#'
#'                  \code{
#'                    env <- envelope(X, nsim=999, savefuns=TRUE,
#'                                    simulate=expression(runifpoint(X$n, win=X$window)))
#'                  }
#'            \item Perform the test
#'
#'                  \code{
#'                    res <- global_envelope_test(env)
#'                  }
#'            \item Plot the result
#'
#'                  \code{
#'                    plot(res)
#'                  }
#'          }
#'    \item A goodness-of-fit of a parametric model (composite hypothesis case)
#'          \itemize{
#'            \item Fit the model to your data by means of the function
#'                  \code{\link[spatstat]{ppm}} or \code{\link[spatstat]{kppm}}.
#'                  See the help documentation for possible models.
#'            \item Use \code{\link{dg.global_envelope_test}} to create nsim simulations
#'                  from the fitted model, to calculate the functions you want,
#'                  and to make an adjusted global envelope test.
#'                  See the detailed example in \code{\link{saplings}}.
#'            \item Plot the result
#'
#'                  \code{
#'                    plot(res)
#'                  }
#'          }
#'
#' }
#'
#' @section Functions for modifying sets of functions:
#' It is possible to modify the curve set T_1(r), T_2(r), ..., T_{nsim+1}(r) for the test.
#'
#' \itemize{
#' \item You can choose the interval of distances [r_min, r_max] by \code{\link{crop_curves}}.
#' \item For better visualisation, you can take T(r)-T_0(r) by \code{\link{residual}}.
#' Here T_0(r) is the expectation of T(r) under the null hypothesis.
#' }
#'
#' The function \code{\link{envelope_to_curve_set}} can be used to create a curve_set object
#' from the object returned by \code{\link[spatstat]{envelope}}. An \code{envelope} object can also
#' directly be given to the functions mentioned above in this section.
#'
#' @section Example data (see references on the help pages of each data set):
#' \itemize{
#'  \item \code{\link{adult_trees}}: a point pattern of adult rees
#'  \item \code{\link{cgec}}: centred government expenditure centralization (GEC) ratios (see \code{\link{graph.fanova}})
#'  \item \code{\link{fallen_trees}}: a point pattern of fallen trees
#'  \item \code{\link{GDPtax}}: GDP per capita with country groups and other covariates
#'  \item \code{\link{imageset1}}: a simulated set of images (see \code{\link{graph.fglm2d}}, \code{\link{frank.fglm2d}})
#'  \item \code{\link{rimov}}: water termperature curves in 365 days of the 36 years
#'  \item \code{\link{saplings}}: a point pattern of saplings (see \code{\link{dg.global_envelope_test}})
#' }
#' The data sets are used to show examples of the functions of the library.
#'
#' @section Number of simulations:
#'
#' Note that the recommended minimum number of simulations for the rank
#' envelope test based on a single function is nsim=2499, while for the
#' "erl", "cont", "area", "qdir" and "st" global envelope tests and deviation tests,
#' a lower number of simulations can be used, although the Monte Carlo error is obviously larger
#' with a small number of simulations.
#' For increasing number of simulations, all the global rank envelopes approach the same curves.
#'
#' Mrkvička et al. (2017) discussed the number of simulations for tests based on many functions.
#'
#' @author
#' Mari Myllymäki (mari.j.myllymaki@@gmail.com, mari.myllymaki@@luke.fi),
#' Tomáš Mrkvička (mrkvicka.toma@@gmail.com),
#' Henri Seijo (henri.seijo@@iki.fi),
#' Pavel Grabarnik (gpya@@rambler.ru),
#' Ute Hahn (ute@@math.au.dk)
#'
#' @references
#' Myllymäki, M., Grabarnik, P., Seijo, H. and Stoyan. D. (2015) Deviation test construction and power comparison for marked spatial point patterns. Spatial Statistics 11: 19-34. doi: 10.1016/j.spasta.2014.11.004
#'
#' Myllymäki, M., Mrkvička, T., Grabarnik, P., Seijo, H. and Hahn, U. (2017) Global envelope tests for spatial point patterns. Journal of the Royal Statistical Society: Series B (Statistical Methodology), 79: 381–404. doi: 10.1111/rssb.12172
#'
#' Mrkvička, T., Myllymäki, M. and Hahn, U. (2017) Multiple Monte Carlo testing, with applications in spatial point processes. Statistics & Computing 27 (5): 1239-1255. doi: 10.1007/s11222-016-9683-9
#'
#' Mrkvička, T., Soubeyrand, S., Myllymäki, M., Grabarnik, P., and Hahn, U. (2016) Monte Carlo testing in spatial statistics, with applications to spatial residuals. Spatial Statistics 18, Part A: 40-53. doi: http://dx.doi.org/10.1016/j.spasta.2016.04.005
#'
#' Mrkvička, T., Myllymäki, M., Jilek, M. and Hahn, U. (2018) A one-way ANOVA test for functional data with graphical interpretation. arXiv:1612.03608 [stat.ME] (http://arxiv.org/abs/1612.03608)
#'
#' Mrkvička, T., Myllymäki, M. and Narisetty, N. N. (2019) New methods for multiple testing in permutation inference for the general linear model.
#'
#' Mrkvička, T., Roskovec, T. and Rost, M. (2019) A nonparametric graphical tests of significance in functional GLM. arXiv:1902.04926 [stat.ME]
#' @name GET-package
#' @docType package
#' @aliases GET-package
NULL
