void main() {
  gibAusObFertig(true);
  gibAusObFertig(false);
  gibAusObFertig(true);
}

void gibAusObFertig(bool isFertig) {
  if (!isFertig) {
    print(isFertig);
  }
}
