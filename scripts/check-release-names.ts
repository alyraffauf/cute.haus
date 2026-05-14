// Every helm release in helmfile.yaml that points to a local chart
// (./charts/<name>) must reference an actual k8s/charts/<name>/Chart.yaml.

const HELMFILE = "k8s/helmfile.yaml";

type Release = { name: string; chart: string };
type Helmfile = { releases: Release[] };

export async function checkReleaseNames(): Promise<string[]> {
  const helmfile = Bun.YAML.parse(await Bun.file(HELMFILE).text()) as Helmfile;
  const errors: string[] = [];

  for (const release of helmfile.releases) {
    const isLocalChart = release.chart.startsWith("./charts/");
    if (!isLocalChart) continue;

    const chartYaml = release.chart.replace(/^\.\//, "k8s/") + "/Chart.yaml";
    const exists = await Bun.file(chartYaml).exists();
    if (!exists) {
      errors.push(
        `release '${release.name}' points to ${release.chart} but ${chartYaml} does not exist`,
      );
    }
  }

  return errors;
}
