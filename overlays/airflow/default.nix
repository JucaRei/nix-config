{ excalibur-packages, ... }:
final: prev: {
  apache-airflow = excalibur-packages.packages.${prev.system}.airflow;
}
