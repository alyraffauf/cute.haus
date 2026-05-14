// Every `integration: forward-auth` OIDC client must have a matching app in
// the forward-auth chart, and vice versa.

const OIDC_CLIENTS_FILE = "ansible/playbooks/vars/oidc-clients.yml";
const FORWARD_AUTH_VALUES_FILE = "k8s/values/secrets/forward-auth.yaml";
const SLUG_PREFIX = "forward-auth-";

type OIDCClient = { slug: string; integration?: string };
type OIDCFile = { oidc_clients: OIDCClient[] };
type ChartFile = { apps?: Record<string, unknown> };

async function readYaml<T>(path: string): Promise<T> {
  return Bun.YAML.parse(await Bun.file(path).text()) as T;
}

function difference(a: Set<string>, b: Set<string>): string[] {
  const result: string[] = [];
  for (const item of a) {
    if (!b.has(item)) result.push(item);
  }
  return result.sort();
}

export async function checkForwardAuth(): Promise<string[]> {
  const oidc = await readYaml<OIDCFile>(OIDC_CLIENTS_FILE);
  const chart = await readYaml<ChartFile>(FORWARD_AUTH_VALUES_FILE);

  const forwardAuthClients = oidc.oidc_clients.filter(
    (client) => client.integration === "forward-auth",
  );

  const errors: string[] = [];

  // Every forward-auth client's slug must start with `forward-auth-` so the
  // integration task can derive the Deployment name from it.
  const slugsWithBadPrefix: string[] = [];
  for (const client of forwardAuthClients) {
    if (!client.slug.startsWith(SLUG_PREFIX))
      slugsWithBadPrefix.push(client.slug);
  }
  if (slugsWithBadPrefix.length > 0) {
    errors.push(
      `OIDC slug(s) missing '${SLUG_PREFIX}' prefix: ${slugsWithBadPrefix.join(", ")}`,
    );
  }

  // The app name is the slug with the prefix stripped, e.g.
  // `forward-auth-navidrome` → `navidrome`. That must equal a key in the chart.
  const oidcAppNames = new Set(
    forwardAuthClients.map((client) => client.slug.replace(SLUG_PREFIX, "")),
  );
  const chartAppNames = new Set(Object.keys(chart.apps ?? {}));

  const onlyInOIDC = difference(oidcAppNames, chartAppNames);
  if (onlyInOIDC.length > 0) {
    errors.push(
      `OIDC client(s) without a matching app in ${FORWARD_AUTH_VALUES_FILE}: ${onlyInOIDC.join(", ")}`,
    );
  }

  const onlyInChart = difference(chartAppNames, oidcAppNames);
  if (onlyInChart.length > 0) {
    errors.push(
      `App(s) in ${FORWARD_AUTH_VALUES_FILE} without a matching OIDC client: ${onlyInChart.join(", ")}`,
    );
  }

  return errors;
}
