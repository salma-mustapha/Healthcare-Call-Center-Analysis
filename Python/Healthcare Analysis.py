import pandas as pd
calls = pd.read_csv("total-call-volume.csv", header=1)
print(calls.head())
wait = pd.read_csv("average-call-wait-time-june-2026.csv")

print(wait.head())
abandonment = pd.read_csv("average-call-abandonment-rate.csv", header=1)

print(abandonment.head())
print(calls.columns.tolist())
print(wait.columns.tolist())
print(abandonment.columns.tolist())
calls["Reporting Period"] = pd.to_datetime(
    calls["Reporting Period"],
    format="%b-%y"
)

wait["Reporting Period"] = pd.to_datetime(
    wait["Reporting Period"],
    format="%b-%y"
)

abandonment["Reporting Period"] = pd.to_datetime(
    abandonment["Reporting Period"],
    format="%B %Y"
)
calls_clean = calls[
    ["Reporting Period", "County Name", "Total Number of Calls Received"]
]
wait_clean = wait[
    ["Reporting Period", "County Name", "Average Wait Time All Languages"]
]
abandonment_clean = abandonment[
    ["Reporting Period", "County Name", "Average Abandonment Rate"]
]
df = calls_clean.merge(
    wait_clean,
    on=["Reporting Period", "County Name"],
    how="inner"
)
df = df.merge(
    abandonment_clean,
    on=["Reporting Period", "County Name"],
    how="inner"
)
print(df.head())
print(df.shape)
df["Average Wait Minutes"] = (
    pd.to_timedelta(
        df["Average Wait Time All Languages"],
        errors="coerce"
    ).dt.total_seconds() / 60
)
df["Average Abandonment Rate"] = pd.to_numeric(
    df["Average Abandonment Rate"],
    errors="coerce"
)
# Convert call volume to numeric
df["Total Number of Calls Received"] = (
    df["Total Number of Calls Received"]
    .astype(str)
    .str.replace(",", "", regex=False)
)

df["Total Number of Calls Received"] = pd.to_numeric(
    df["Total Number of Calls Received"],
    errors="coerce"
)

df["Abandonment Rate Percent"] = (
    df["Average Abandonment Rate"] * 100
)
print(
    df[
        [
            "County Name",
            "Average Wait Minutes",
            "Abandonment Rate Percent"
        ]
    ].head(10)
)
# QUESTION 1: Relationship between wait time and abandonment

# Calculate the correlation
correlation = df["Average Wait Minutes"].corr(
    df["Abandonment Rate Percent"]
)

print("Correlation between average wait time and abandonment rate:", correlation)
# Visualize the relationship

import matplotlib.pyplot as plt

plt.figure(figsize=(8, 6))

plt.scatter(
    df["Average Wait Minutes"],
    df["Abandonment Rate Percent"]
)

plt.xlabel("Average Wait Time (Minutes)")
plt.ylabel("Abandonment Rate (%)")
plt.title("Average Wait Time vs. Abandonment Rate")

plt.show()
# QUESTION 2: Multiple regression

# Rename columns to make the regression easier to write
df = df.rename(columns={
    "County Name": "County",
    "Total Number of Calls Received": "Call_Volume",
    "Average Wait Minutes": "Wait_Time",
    "Abandonment Rate Percent": "Abandonment_Rate",
    "Reporting Period": "Month"
})

# Load the regression tool
import statsmodels.formula.api as smf

# Build the regression model
model = smf.ols(
    "Abandonment_Rate ~ Wait_Time + Call_Volume + C(County) + C(Month)",
    data=df
).fit()

# Display the results
print(model.summary())
print(model.summary())
# Create high-abandonment category
df["High_Abandonment"] = (
    df["Abandonment_Rate"] >= 0.30
)

print("\nHigh-abandonment observations:")
print(df["High_Abandonment"].value_counts())
# Compare high vs. lower abandonment observations
high_abandonment_summary = df.groupby("High_Abandonment")[
    ["Wait_Time", "Call_Volume"]
].mean()

print("\nAverage wait time and call volume by abandonment category:")
print(high_abandonment_summary)
# High-abandonment observations by county
county_abandonment = (
    df.groupby("County")["High_Abandonment"]
    .mean()
    .sort_values(ascending=False)
)

print("\nPercentage of observations with high abandonment by county:")
print((county_abandonment * 100).round(1))

# County-level high-abandonment profile
county_profile = (
    df.groupby("County")
    .agg(
        Total_Observations=("High_Abandonment", "size"),
        High_Abandonment_Observations=("High_Abandonment", "sum"),
        High_Abandonment_Percent=("High_Abandonment", "mean")
    )
    .sort_values("High_Abandonment_Percent", ascending=False)
)

county_profile["High_Abandonment_Percent"] = (
    county_profile["High_Abandonment_Percent"] * 100
).round(1)

print("\nCounty-level high-abandonment profile:")
print(county_profile)
# Monthly high-abandonment profile
monthly_profile = (
    df.groupby("Month")
    .agg(
        Total_Observations=("High_Abandonment", "size"),
        High_Abandonment_Observations=("High_Abandonment", "sum"),
        High_Abandonment_Percent=("High_Abandonment", "mean")
    )
)

monthly_profile["High_Abandonment_Percent"] = (
    monthly_profile["High_Abandonment_Percent"] * 100
).round(1)

print("\nMonthly high-abandonment profile:")
print(monthly_profile)
# Wait-time profile by abandonment category
wait_profile = (
    df.groupby("High_Abandonment")["Wait_Time"]
    .agg(["min", "mean", "median", "max"])
    .round(2)
)

print("\nWait-time profile by abandonment category:")
print(wait_profile)

# Convert high-abandonment category to numeric 0/1
df["High_Abandonment"] = df["High_Abandonment"].astype(int)

# Q5: Compare call volume by abandonment category

call_volume_profile = df.groupby("High_Abandonment")["Call_Volume"].agg(
    ["min", "mean", "median", "max"]
)

print("\nCall-volume profile by abandonment category:")
print(call_volume_profile)
