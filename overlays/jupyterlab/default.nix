{ excalibur-jupyterlab, ... }:
final: prev: {
  jupyterlab = excalibur-jupyterlab.packages.${prev.system}.default;
}
