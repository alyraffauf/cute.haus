// Every deployed local Helm chart must reference an actual
// k8s/charts/<name>/Chart.yaml. During the Flux migration, deployed charts can
// be declared in helmfile.yaml or Flux HelmRelease manifests.

const HELMFILE = "k8s/helmfile.yaml";
const FLUX_DIRS = [
  "k8s/flux/infra-crds",
  "k8s/flux/infra-core",
  "k8s/flux/platform",
  "k8s/flux/apps",
  "k8s/flux/external-routes",
];

type Release = { name: string; chart: string };
type Helmfile = { releases: Release[] };
type HelmRelease = {
  kind?: string;
  metadata?: { name?: string };
  spec?: { chart?: { spec?: { chart?: string } } };
};

function splitYamlDocuments(text: string): string[] {
  return text
    .split(/^---\s*$/m)
    .map((doc) => doc.trim())
    .filter(Boolean);
}

async function fluxLocalReleases(): Promise<Release[]> {
  const releases: Release[] = [];

  for (const dir of FLUX_DIRS) {
    const glob = new Bun.Glob(`${dir}/**/*.yaml`);
    for await (const path of glob.scan(".")) {
      const text = await Bun.file(path).text();
      for (const doc of splitYamlDocuments(text)) {
        const parsed = Bun.YAML.parse(doc) as HelmRelease | null;
        if (parsed?.kind !== "HelmRelease") continue;

        const chart = parsed.spec?.chart?.spec?.chart;
        if (!chart?.startsWith("./k8s/charts/")) continue;

        releases.push({
          name: parsed.metadata?.name ?? path,
          chart,
        });
      }
    }
  }

  return releases;
}

async function helmfileLocalReleases(): Promise<Release[]> {
  if (!(await Bun.file(HELMFILE).exists())) return [];

  const helmfile = Bun.YAML.parse(await Bun.file(HELMFILE).text()) as Helmfile;
  return helmfile.releases.filter((release) =>
    release.chart.startsWith("./charts/"),
  );
}

function chartYamlPath(chart: string): string {
  return (
    chart.replace(/^\.\/charts\//, "k8s/charts/").replace(/^\.\//, "") +
    "/Chart.yaml"
  );
}

export async function checkReleaseNames(): Promise<string[]> {
  const errors: string[] = [];

  const releases = [
    ...(await helmfileLocalReleases()),
    ...(await fluxLocalReleases()),
  ];

  for (const release of releases) {
    const chartYaml = chartYamlPath(release.chart);
    const exists = await Bun.file(chartYaml).exists();
    if (!exists) {
      errors.push(
        `release '${release.name}' points to ${release.chart} but ${chartYaml} does not exist`,
      );
    }
  }

  return errors;
}
