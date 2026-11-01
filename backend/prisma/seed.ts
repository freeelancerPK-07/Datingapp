import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting Database Seeding...');

  // 1. Create Default Admin Settings
  await prisma.adminSetting.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      isFreezeBalance: false,
      isVideoConnectionEnabled: true,
      paymentUpiId: 'linkup@ybl',
    },
  });

  // 2. Create Sample Creators
  const creatorsData = [
    {
      name: 'Aanya Sharma',
      phone: '+919876543210',
      email: 'aanya@linkup.app',
      bio: 'Bollywood dancer & lifestyle creator. Love sharing positive vibes!',
      city: 'Mumbai',
      state: 'Maharashtra',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
      tier: 'VIP',
      videoCallPrice: 500,
      voiceCallPrice: 300,
      photoPrice: 200,
      rating: 4.9,
      reviewCount: 128,
      profession: 'Dancer & Influencer',
      followers: '142K',
      tags: ['Dance', 'Lifestyle', 'Hindi'],
      languages: ['English', 'Hindi'],
    },
    {
      name: 'Rohan Mehra',
      phone: '+919876543211',
      email: 'rohan@linkup.app',
      bio: 'Fitness trainer & nutrition coach. Let’s talk wellness and gains!',
      city: 'Delhi',
      state: 'Delhi',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
      tier: 'Gold',
      videoCallPrice: 400,
      voiceCallPrice: 250,
      photoPrice: 150,
      rating: 4.8,
      reviewCount: 94,
      profession: 'Fitness Coach',
      followers: '89K',
      tags: ['Fitness', 'Workout', 'English'],
      languages: ['English', 'Hindi', 'Punjabi'],
    },
    {
      name: 'Kavya Nair',
      phone: '+919876543212',
      email: 'kavya@linkup.app',
      bio: 'Fashion designer and visual storyteller. Living between art galleries & boutiques.',
      city: 'Bangalore',
      state: 'Karnataka',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
      tier: 'VIP',
      videoCallPrice: 600,
      voiceCallPrice: 350,
      photoPrice: 250,
      rating: 5.0,
      reviewCount: 210,
      profession: 'Fashion Designer',
      followers: '230K',
      tags: ['Fashion', 'PastelAesthetic', 'Coffee', 'Art'],
      languages: ['English', 'Tamil', 'Malayalam'],
    },
    {
      name: 'Sneha Roy',
      phone: '+919876543213',
      email: 'sneha@linkup.app',
      bio: 'Singer and acoustic musician. Drop in for song requests & acoustic chills.',
      city: 'Kolkata',
      state: 'West Bengal',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
      tier: 'Silver',
      videoCallPrice: 300,
      voiceCallPrice: 200,
      photoPrice: 100,
      rating: 4.7,
      reviewCount: 65,
      profession: 'Acoustic Singer',
      followers: '45K',
      tags: ['Music', 'Singing', 'Acoustic'],
      languages: ['English', 'Bengali', 'Hindi'],
    },
  ];

  for (const c of creatorsData) {
    const user = await prisma.user.upsert({
      where: { phone: c.phone },
      update: {},
      create: {
        phone: c.phone,
        email: c.email,
        role: 'CREATOR',
        isVerified: true,
        profile: {
          create: {
            name: c.name,
            bio: c.bio,
            city: c.city,
            state: c.state,
            avatarUrl: c.avatarUrl,
            galleryPhotos: [c.avatarUrl],
            interests: c.tags,
            languages: c.languages,
            isCompleted: true,
          },
        },
        wallet: {
          create: {
            balance: 5000,
          },
        },
        creator: {
          create: {
            tier: c.tier,
            videoCallPrice: c.videoCallPrice,
            voiceCallPrice: c.voiceCallPrice,
            photoPrice: c.photoPrice,
            rating: c.rating,
            reviewCount: c.reviewCount,
            profession: c.profession,
            followers: c.followers,
            tags: c.tags,
            languages: c.languages,
          },
        },
      },
    });

    console.log(`✅ Seeded Creator: ${c.name} (${user.id})`);
  }

  console.log('🎉 Seeding successfully completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

