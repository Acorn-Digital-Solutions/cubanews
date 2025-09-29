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

function getPublicationLogo(item: NewsItem) {
  let imageLogoSrc = "";
  switch (item.source) {
    case NewsSourceName.ADNCUBA:
      imageLogoSrc = "/source_logos/adncuba1.webp";
      break;
    case NewsSourceName.CATORCEYMEDIO:
      imageLogoSrc = "/source_logos/14ymedio1.jpg";
      break;
    case NewsSourceName.CIBERCUBA:
      imageLogoSrc = "/source_logos/cibercuba1.png";
      break;
    case NewsSourceName.DIARIODECUBA:
      imageLogoSrc = "/source_logos/ddc1.webp";
      break;
    case NewsSourceName.ELTOQUE:
      imageLogoSrc = "/source_logos/eltoque.png";
      break;
    case NewsSourceName.CUBANET:
      imageLogoSrc = "/source_logos/cubanet2.jpeg";
      break;
    default:
      break;
  }
  return (
    <Image width={20} height={100} alt="Publication Logo" src={imageLogoSrc} />
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
    item.id ? localStorage.getItem(item.id?.toString()) : false
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
          {/* <NewsItemImage image={item.image}></NewsItemImage> */}
          <Typography>{item.image}</Typography>
          <Typography level="body-sm">{item.content} ...</Typography>
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
