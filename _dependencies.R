# Packages the book needs that no chapter loads with library(), so renv's
# dependency scan would otherwise miss them (and renv::snapshot() would drop
# them from renv.lock). This file is never run.
library(broom.helpers)  # gtsummary::tbl_regression()
library(xgboost)        # boost_tree() engine in week 15
library(downlit)        # code-link in the rendered book
library(xml2)           # code-link in the rendered book
