{ excalibur-packages, ... }:
final: prev: {
  label_studio = excalibur-packages.packages.${prev.system}.label-studio;
}
