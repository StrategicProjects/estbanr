# estbanr: Access 'ESTBAN' Monthly Banking Statistics by Municipality from the Brazilian Central Bank

Download, read and tidy the 'ESTBAN' ('Estatistica Bancaria Mensal por
Municipio'), the monthly banking statistics published by the Brazilian
Central Bank ('Banco Central do Brasil') for every bank branch and
municipality in Brazil, with balance-sheet accounts ('verbetes' of the
'COSIF' chart of accounts) such as credit operations, deposits and
savings. Files are fetched from the official site
<https://www.bcb.gov.br/estatisticas/estatisticabancariamunicipios> with
an idempotent local cache, read from their 'Latin-1' CSV layout into
tibbles, optionally filtered by state, and aggregated by municipality.
Includes tools to detect and impute institution-month non-reports (an
institution present in the file with every account equal to zero), which
would otherwise be mistaken for zero balances.

## See also

Useful links:

- <https://strategicprojects.github.io/estbanr/>

- <https://github.com/StrategicProjects/estbanr>

- Report bugs at <https://github.com/StrategicProjects/estbanr/issues>

## Author

**Maintainer**: Andre Leite <leite@castlab.org>
([ORCID](https://orcid.org/0000-0002-4718-9766))

Authors:

- Andre Leite <leite@castlab.org>
  ([ORCID](https://orcid.org/0000-0002-4718-9766))

- Marcos Wasiliew <marcos.wasiliew@sepe.pe.gov.br>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))

- Júlia Nascimento Barreto <juliabarreto@gd.seplag.pe.gov.br>
