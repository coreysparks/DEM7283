import pandas as pd
import polars as pl
import svy


def make_svy_sample(df, design, cat_cols=None, dummy_cols=None):
    """
    Prepare a pandas DataFrame for use with the svy package.

    Handles all required type conversions:
      - Casts stratum and PSU columns to string (svy requirement)
      - Casts categorical columns to string (avoids Polars cat->Float64 errors)
      - Creates float dummy variables for GLM predictors
      - Converts to Polars and returns a svy.Sample

    Parameters
    ----------
    df : pd.DataFrame
        Input data (pandas).
    design : svy.Design
        Survey design object specifying stratum, psu, and weight columns.
    cat_cols : list of str, optional
        Columns that are categorical strings (e.g. created with pd.cut).
        These are cast to str to avoid Polars categorical dtype issues.
    dummy_cols : list of str, optional
        Columns to one-hot encode for use as GLM predictors.
        Dummies are created with drop_first=True.

    Returns
    -------
    sample : svy.Sample
    dummies : pd.DataFrame
        The dummy variable columns (empty DataFrame if dummy_cols is None).
        Use dummies.columns.tolist() to get predictor names for sample.glm.fit().
    """
    df = df.copy()

    df[design.stratum] = df[design.stratum].astype(int).astype(str)
    df[design.psu] = df[design.psu].astype(int).astype(str)

    if cat_cols:
        df[cat_cols] = df[cat_cols].astype(str)

    dummies = pd.DataFrame()
    if dummy_cols:
        dummies = pd.get_dummies(df[dummy_cols], drop_first=True, dtype=float)
        df = pd.concat([df, dummies], axis=1)

    sample = svy.Sample(data=pl.from_pandas(df), design=design)
    return sample, dummies


def svy_glm_results(fit):
    """
    Extract GLM results from a svy fit object as a pandas DataFrame.

    The svy GLM result has no .summary() or .params — use this instead.

    Returns
    -------
    pd.DataFrame with columns: term, estimate, std_err, conf_low, conf_high,
                                statistic, p_value, df
    """
    return fit.to_polars().to_pandas()


def svy_glm_coefs(fit):
    """
    Return non-intercept coefficients as a pandas DataFrame, for plotting
    or comparison with statsmodels results.
    """
    results = svy_glm_results(fit)
    return results[results["term"] != "_intercept_"].reset_index(drop=True)
