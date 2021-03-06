% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_positions_from_unique_id.R
\name{get_positions_from_device_id}
\alias{get_positions_from_device_id}
\title{Get positions from device id}
\usage{
get_positions_from_device_id(
  url,
  user,
  pass,
  device_id,
  path = "api/positions?from=2010-01-01T22\%3A00\%3A00Z&to=2020-12-31T22\%3A00\%3A00Z"
)
}
\arguments{
\item{url}{The url of your traccar api}

\item{user}{The username for your traccar api}

\item{pass}{The password for your traccar api}

\item{device_id}{The id for a registered HCW on the traccar api}

\item{path}{API path}
}
\value{
A dataframe
}
\description{
Retrieve positions from api/positions using device_id
}
