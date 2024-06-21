"use client";

import { Container, Typography, Divider, Chip, Box, Stack } from "@mui/joy";
import CopyrightIcon from "@mui/icons-material/Copyright";
import Image from "next/image";

export default function About() {
  return (
    <Container>
      <Stack>
        <Box>
          <Box
            sx={{
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              padding: 6,
            }}
          >
            <Stack direction="row">
              <Image
                src={`cuban-flag.svg`}
                height={70}
                width={100}
                alt="Cuban FLag"
              />
              <Stack
                direction="row"
                style={{ alignItems: "center", paddingLeft: 7 }}
              >
                <Typography level="h1" style={{ color: "#CC0D0D" }}>
                  Cuba
                </Typography>
                <Typography level="h1" style={{ color: "#002590" }}>
                  News
                </Typography>
              </Stack>
            </Stack>
          </Box>
        </Box>

        {/* Spanish */}
        <Typography level="h2" sx={{ mb: 1, mt: 2 }}>
          Nuestra mission
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          El objetivo principal de esta web es amplificar el mensaje de la
          prensa independiente cubana, brindar un único punto de acceso a las
          últimas noticias acerca de Cuba y combatir la propaganda y
          desinformación del régimen dictatorial de La Habana. Está orientado
          principalmente a cubanos dentro de Cuba con conexiones a internet
          lentas y limitadas, pero igualmente a aquellas personas en el resto
          del mundo que no sepan de la variedad de fuentes de información
          disponibles.
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          Este trabajo ha sido realizado completamente por voluntarios en su
          tiempo libre. Los costos de mantener el sitio son cubiertos
          completamente por fondos personales. Nuestra motivación es el amor a
          la libertad, la democracia y los derechos humanos. Como cubano
          quisiera ver a mi país libre de la dictadura comunista que lo oprime.
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          Valoramos tu opinion, envianos un email a{" "}
          <a href="mailto:cubanews.icu@gmail.com">cubanews.icu@gmail.com</a>
        </Typography>

        <Typography level="body-md">Firmado, El equipo de Cuba News</Typography>

        {/* English */}
        <Typography level="h2" sx={{ mb: 1, mt: 2 }}>
          Our mission
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          The main purpose of this website is to amplify the message of the
          independent Cuban media, provide a single entry point to find the
          latest news about Cuba and combat the propaganda and misinformation
          spread by the dictatorial regime in Havana. Cuba News is primarily
          aimed at those inside Cuba with limited and slow internet access, but
          also at those around the world that may not be aware of the variety of
          independent Cuban newspapers.
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          This work has been done by volunteers in their free time. The running
          of the website is fully financed with personal funds. Our drive is our
          belief in freedom, democracy and humans rights. As a Cuban myself, I
          want to see my country free of the communist dictatorship that
          currently oppresses it.
        </Typography>

        <Typography level="body-lg" sx={{ mb: 1 }}>
          We value your feedback, please email us at{" "}
          <a href="mailto:cubanews.icu@gmail.com">cubanews.icu@gmail.com</a>
        </Typography>

        <Typography level="body-md" sx={{ mb: 1 }}>
          Signed, The Cuba News team
        </Typography>
      </Stack>

      <Divider sx={{ m: 4 }}>
        <Chip
          variant="outlined"
          startDecorator={<CopyrightIcon />}
          sx={{ p: 1 }}
        >
          Cuba News
        </Chip>
      </Divider>
    </Container>
  );
}
