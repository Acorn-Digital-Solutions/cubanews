import {
  Link,
  Typography,
  Card,
  Stack,
  Chip,
  Divider,
  CardOverflow,
  CardContent,
} from "@mui/joy";
import {
  NewsItem,
  NewsSourceName,
  Interaction,
  getNewsSourceDisplayName,
} from "../interfaces";
import moment from "moment";
import Image from "next/image";
import "moment/locale/es";
import ThumbUp from "@mui/icons-material/ThumbUp";
import { useEffect, useState } from "react";
import { NewsItemImage } from "./NewsItemImage";

moment.locale("es");

type NewsItemProps = {
  item: NewsItem;
};

function getImageLogoSrc(newsSourceName: NewsSourceName): string {
  switch (newsSourceName) {
    case NewsSourceName.ADNCUBA:
      return "/source_logos/adncuba1.webp";
    case NewsSourceName.CATORCEYMEDIO:
      return "/source_logos/14ymedio1.jpg";
    case NewsSourceName.CIBERCUBA:
      return "/source_logos/cibercuba1.png";
    case NewsSourceName.DIARIODECUBA:
      return "/source_logos/ddc1.webp";
    case NewsSourceName.ELTOQUE:
      return "/source_logos/eltoque.png";
    case NewsSourceName.CUBANET:
      return "/source_logos/cubanet2.jpeg";
    case NewsSourceName.CUBANOS_POR_EL_MUNDO:
      return "/source_logos/cubanosporelmundo.jpg";
    case NewsSourceName.DIRECTORIO_CUBANO:
      return "/source_logos/directoriocubano.png";
    case NewsSourceName.MARTI_NOTICIAS:
      return "/source_logos/martinoticias.png";
    case NewsSourceName.PERIODICO_CUBANO:
      return "/source_logos/periodicocubano.png";
  }
}

function getPublicationLogo(item: NewsItem) {
  let imageLogoSrc = getImageLogoSrc(item.source);
  return (
    <Image width={20} height={20} alt="Publication Logo" src={imageLogoSrc} />
  );
}

function getTagsSection(item: NewsItem): JSX.Element {
  if (item.tags.length > 0) {
    return (
      <>
        <Divider orientation="vertical" sx={{ ml: 1, mr: 1 }} />
        {item.tags.map((tagName: string) => (
          <Chip variant="outlined" key={tagName}>
            <Typography
              level="body-xs"
              fontWeight="lg"
              textColor="text.secondary"
            >
              {tagName}
            </Typography>
          </Chip>
        ))}
      </>
    );
  }
  return <></>;
}

export default function NewsItemComponent({ item }: NewsItemProps) {
  const [liked, setLiked] = useState(
    item.id ? localStorage.getItem(item.id?.toString()) : false,
  );
  useEffect(() => {
    refreshLiked();
  });

  function refreshLiked() {
    if (item.id) {
      const liked = localStorage.getItem(item.id?.toString());
      if (liked) {
        setLiked(true);
      } else {
        setLiked(false);
      }
    }
  }

  function onNewsInteraction(item: NewsItem, interaction: Interaction) {
    fetch(`/api/interactions`, {
      method: "POST",
      body: JSON.stringify({
        feedid: item.id,
        interaction: interaction,
      }),
    }).then(() => {
      if (interaction === Interaction.LIKE) {
        item.interactions.like++;
        localStorage.setItem(item.id.toString(), "true");
        refreshLiked();
      } else if (interaction === Interaction.VIEW) {
        item.interactions.view++;
      }
    });
  }

  function getInteractionsSection(item: NewsItem): JSX.Element {
    if (liked) {
      const likeNumber = item.interactions.like + item.interactions.view;
      return (
        <Chip
          variant="plain"
          disabled={true}
          startDecorator={<ThumbUp sx={{ fontSize: 12 }} />}
          size="sm"
          onClick={() => onNewsInteraction(item, Interaction.LIKE)}
          sx={{ ml: "auto", alignSelf: "center" }}
          color="primary"
        >
          {likeNumber}
        </Chip>
      );
    }

    return (
      <Chip
        variant="outlined"
        startDecorator={<ThumbUp sx={{ fontSize: 12 }} />}
        size="sm"
        onClick={() => onNewsInteraction(item, Interaction.LIKE)}
        sx={{ ml: "auto", alignSelf: "center" }}
        color="primary"
      >
        Interesante
      </Chip>
    );
  }

  return (
    <Stack spacing={4}>
      <Card variant="outlined" sx={{ padding: 2 }}>
        <CardContent>
          <Link
            href={item.url}
            target="_blank"
            onClick={() => onNewsInteraction(item, Interaction.VIEW)}
          >
            <Typography level="h2" fontSize="xl">
              {item.title}
            </Typography>
          </Link>
          <Stack direction="row" spacing={2} alignItems="flex-start">
            {item.image ? <NewsItemImage image={item.image} /> : <></>}
            <Typography level="body-sm" flex={1}>
              {item.content} ...
            </Typography>
          </Stack>
        </CardContent>
        <CardOverflow variant="soft" sx={{ bgcolor: "background.level1" }}>
          <Divider inset="context" />
          <CardContent orientation="horizontal" sx={{ pt: 1, pb: 1 }}>
            <Stack
              direction="row"
              spacing={1}
              flexWrap="wrap"
              useFlexGap
              alignItems="center"
              divider={
                <Divider orientation="vertical" sx={{ ml: 0.5, mr: 0.5 }} />
              }
            >
              <Typography
                level="body-xs"
                fontWeight="md"
                textColor="text.secondary"
              >
                {moment(item.isoDate).fromNow()}
              </Typography>
              <Stack direction="row" spacing={1}>
                {getPublicationLogo(item)}
                <Typography
                  level="body-xs"
                  fontWeight="md"
                  textColor="text.secondary"
                >
                  {getNewsSourceDisplayName(item)}
                </Typography>
              </Stack>
              {/* We don't have any tags yet so I'll remove it because it adds an extra divider */}
              {/* {getTagsSection(item)} */}
            </Stack>
            {getInteractionsSection(item)}
          </CardContent>
        </CardOverflow>
      </Card>
    </Stack>
  );
}
