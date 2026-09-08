"""FounderFocus CLI domain model and report exporters."""

import csv


class FounderFocus:
    """Represent a startup and determine whether it is acquisition-ready."""

    def __init__(self, name):
        self.name = name
        self.sector = "Unknown"
        self.funding = 0.0

    def set_sector(self, sector):
        self.sector = str(sector).strip()
        return self

    def set_funding(self, funding):
        funding_value = float(funding)
        if funding_value < 0:
            raise ValueError("Funding cannot be negative.")
        self.funding = funding_value
        return self

    def is_acquisition_ready(self):
        eligible_sectors = {"ai", "fintech", "saas"}
        return self.funding >= 500_000 and self.sector.lower() in eligible_sectors

    def summary(self):
        readiness = "Yes" if self.is_acquisition_ready() else "No"
        return (
            "FounderFocus Startup Report\n"
            f"Name: {self.name}\n"
            f"Sector: {self.sector}\n"
            f"Funding: ${self.funding:,.2f}\n"
            f"Acquisition-ready: {readiness}"
        )

    def export_summary_to_txt(self, filename):
        with open(filename, "w", encoding="utf-8") as file:
            file.write(self.summary())


def export_to_csv(cli_obj, filename):
    """Export one FounderFocus object as a CSV row."""
    with open(filename, "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["name", "sector", "funding", "acquisition_ready"])
        writer.writerow([
            cli_obj.name,
            cli_obj.sector,
            f"{cli_obj.funding:.2f}",
            cli_obj.is_acquisition_ready(),
        ])


if __name__ == "__main__":
    demo = FounderFocus("AcquiCheck").set_sector("AI").set_funding(750_000)
    print(demo.summary())
